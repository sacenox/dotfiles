const std = @import("std");
const Io = std.Io;
const Value = std.json.Value;

const skill =
    \\dot-compose renders dotfile templates with machine-specific values.
    \\
    \\Layout:
    \\  tmpl/    mirrors $HOME. tmpl/.config/nvim/init.lua renders to ~/.config/nvim/init.lua
    \\  values/  one JSON file per machine/profile, e.g. values/mac.json
    \\
    \\Template syntax:
    \\  {{ key }}          insert a value from the JSON file
    \\  {{ nested.key }}   walk into nested JSON objects with dots
    \\  Everything else is copied verbatim.
    \\
    \\Values may be strings, numbers or booleans. null renders as empty text.
    \\
    \\Your task, given an existing dotfiles tree:
    \\  1. Move each config file to tmpl/<its path relative to $HOME>.
    \\  2. Replace every machine-specific literal with a {{ }} slot.
    \\     Machine-specific means it differs across machines: fonts, themes,
    \\     usernames, hosts, paths, secrets, tools present on only some machines.
    \\  3. Collect those literals into values/<profile>.json. Group related keys
    \\     in nested objects, e.g. {"font": {"family": "Lilex Nerd Font Mono"}}.
    \\  4. Put secrets in values/secrets.json and gitignore it.
    \\  5. Leave anything identical on every machine as plain text.
    \\
;

pub fn main(init: std.process.Init) !void {
    run(init) catch |e| {
        if (e == error.Message) std.process.exit(1);
        return e;
    };
}

fn run(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;
    const args = try init.minimal.args.toSlice(arena);

    var tmpl_path: ?[]const u8 = null;
    var values_path: ?[]const u8 = null;

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const a = args[i];
        if (std.mem.eql(u8, a, "--skill")) return stdout(io, skill);
        if (std.mem.eql(u8, a, "--tmpl")) {
            i += 1;
            tmpl_path = try arg(args, i, "--tmpl");
        } else if (std.mem.eql(u8, a, "--values")) {
            i += 1;
            values_path = try arg(args, i, "--values");
        } else {
            return fail("unknown argument: {s}", .{a});
        }
    }

    const tmpl = tmpl_path orelse return fail("missing --tmpl", .{});
    const values = values_path orelse return fail("missing --values", .{});

    const home = init.environ_map.get("HOME") orelse return fail("HOME is not set", .{});

    const source = Io.Dir.cwd().readFileAlloc(io, tmpl, arena, .unlimited) catch |e|
        return fail("cannot read template {s}: {t}", .{ tmpl, e });
    const values_json = Io.Dir.cwd().readFileAlloc(io, values, arena, .unlimited) catch |e|
        return fail("cannot read values {s}: {t}", .{ values, e });

    var parsed = std.json.parseFromSliceLeaky(Value, arena, values_json, .{}) catch |e|
        return fail("cannot parse {s}: {t}", .{ values, e });

    // Merge a sibling `secrets.json`, if present, so templates can use secret keys directly.
    if (secretsPath(arena, values)) |secrets_path| {
        if (Io.Dir.cwd().readFileAlloc(io, secrets_path, arena, .unlimited) catch null) |secrets_json| {
            const secrets = std.json.parseFromSliceLeaky(Value, arena, secrets_json, .{}) catch |e|
                return fail("cannot parse {s}: {t}", .{ secrets_path, e });
            parsed = try merge(arena, parsed, secrets);
        }
    }

    const rendered = try render(arena, source, parsed);

    const rel = tmplRelPath(arena, tmpl) catch
        return fail("template path must live under a 'tmpl' directory: {s}", .{tmpl});
    const dest = try std.fs.path.join(arena, &.{ home, rel });

    var af = Io.Dir.cwd().createFileAtomic(io, dest, .{ .make_path = true, .replace = true }) catch |e|
        return fail("cannot create {s}: {t}", .{ dest, e });
    defer af.deinit(io);
    try af.file.writeStreamingAll(io, rendered);
    try af.replace(io);
}

fn arg(args: []const []const u8, i: usize, flag: []const u8) ![]const u8 {
    if (i >= args.len) return fail("{s} needs a path", .{flag});
    return args[i];
}

// Everything after the `tmpl` path component, relative to $HOME.
fn tmplRelPath(arena: std.mem.Allocator, tmpl: []const u8) ![]const u8 {
    var it = std.mem.tokenizeScalar(u8, tmpl, '/');
    var found = false;
    var out: std.ArrayList(u8) = .empty;
    while (it.next()) |part| {
        if (!found) {
            found = std.mem.eql(u8, part, "tmpl");
            continue;
        }
        if (out.items.len != 0) try out.append(arena, '/');
        try out.appendSlice(arena, part);
    }
    if (!found or out.items.len == 0) return error.NotATemplate;
    return out.items;
}

// Path to a sibling `secrets.json` next to the values file, or null when not wanted.
fn secretsPath(arena: std.mem.Allocator, values: []const u8) ?[]const u8 {
    if (std.mem.eql(u8, std.fs.path.basename(values), "secrets.json")) return null;
    const dir = std.fs.path.dirname(values) orelse ".";
    return std.fs.path.join(arena, &.{ dir, "secrets.json" }) catch null;
}

// Shallow merge of two JSON objects; `over` wins on key collisions.
fn merge(arena: std.mem.Allocator, base: Value, over: Value) !Value {
    const base_obj = switch (base) {
        .object => |o| o,
        else => return base,
    };
    const over_obj = switch (over) {
        .object => |o| o,
        else => return base,
    };
    var map: std.json.ObjectMap = .empty;
    var it = base_obj.iterator();
    while (it.next()) |e| try map.put(arena, e.key_ptr.*, e.value_ptr.*);
    var it2 = over_obj.iterator();
    while (it2.next()) |e| try map.put(arena, e.key_ptr.*, e.value_ptr.*);
    return .{ .object = map };
}

fn render(arena: std.mem.Allocator, tmpl: []const u8, root: Value) ![]const u8 {
    var out: std.ArrayList(u8) = .empty;
    var i: usize = 0;
    while (i < tmpl.len) {
        if (tmpl[i] == '{' and i + 1 < tmpl.len and tmpl[i + 1] == '{') {
            const close = std.mem.indexOfPos(u8, tmpl, i + 2, "}}") orelse
                return fail("unclosed '{{{{' at byte {d}", .{i});
            const key = std.mem.trim(u8, tmpl[i + 2 .. close], " \t\r\n");
            const v = lookup(root, key) orelse
                return fail("no value for '{s}'", .{key});
            try emit(arena, &out, key, v);
            i = close + 2;
        } else {
            try out.append(arena, tmpl[i]);
            i += 1;
        }
    }
    return out.items;
}

fn lookup(root: Value, key: []const u8) ?Value {
    if (key.len == 0) return null;
    var cur = root;
    var it = std.mem.splitScalar(u8, key, '.');
    while (it.next()) |part| {
        cur = switch (cur) {
            .object => |o| o.get(part) orelse return null,
            else => return null,
        };
    }
    return cur;
}

fn emit(arena: std.mem.Allocator, out: *std.ArrayList(u8), key: []const u8, v: Value) !void {
    switch (v) {
        .string => |s| try out.appendSlice(arena, s),
        .integer => |n| try out.print(arena, "{d}", .{n}),
        .float => |n| try out.print(arena, "{d}", .{n}),
        .bool => |b| try out.appendSlice(arena, if (b) "true" else "false"),
        .null => {},
        else => return fail("value for '{s}' is not a scalar", .{key}),
    }
}

fn stdout(io: Io, text: []const u8) void {
    var buf: [4096]u8 = undefined;
    var w: Io.File.Writer = .init(.stdout(), io, &buf);
    w.interface.writeAll(text) catch {};
    w.interface.flush() catch {};
}

fn fail(comptime fmt: []const u8, args: anytype) error{Message} {
    std.debug.print("dot-compose: " ++ fmt ++ "\n", args);
    return error.Message;
}
