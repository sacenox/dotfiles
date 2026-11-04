---
name: xfce-computer-use
description: Apply when you need to interact with the desktop as a user would in a xfce desktop environment. Use it to test and verify GUIs or TUIs inside the Kitty terminal.
---

# Control the XFCE desktop on X11

Use `wmctrl`, `xdotool`, `xwininfo`, `maim`, and `kitten` to inspect and control the XFCE desktop on this machine.

## Prepare the environment

Non-GUI shells start with `XDG_SESSION_TYPE=tty` and an empty `DISPLAY` variable. Export `DISPLAY=:0` before you run any X11 command, and store screenshots or sockets in `/tmp/computer-use-shots`.

```bash
	export DISPLAY=:0
```

The screen resolution is `1280x800`. The top `xfce4-panel` occupies `y=0` to `y=27`, and the bottom panel occupies `x=487` to `x=793` from `y=751` to `y=800`. Place windows between `y=27` and `y=750` so that the panels do not cover them.

## Find, focus, move, and close windows

Use `wmctrl` and `xdotool` to manage windows. Both tools, along with `xwininfo -id` and `maim -i`, accept hexadecimal or decimal window IDs.

1. List all open windows with their window ID, workspace, PID, geometry, window class, and title:

```bash
	DISPLAY=:0 wmctrl -lpGx
```

2. Launch a GUI application in the background and poll `xdotool` until its window maps:

```bash
	export DISPLAY=:0
	nohup kitty >/dev/null 2>&1 &
	APP_PID=$!
	for i in {1..30}; do
		WIN_ID=$(xdotool search --onlyvisible --pid "$APP_PID" 2>/dev/null | head -n1)
		[ -n "$WIN_ID" ] && break
		sleep 0.1
	done
```

3. Focus a window and wait until it becomes active:

```bash
	DISPLAY=:0 xdotool windowactivate --sync "$WIN_ID"
```

4. Move and resize a window so that it fits inside the `1280x800` screen:

```bash
	DISPLAY=:0 xdotool windowmove --sync "$WIN_ID" 80 60
	DISPLAY=:0 xdotool windowsize --sync "$WIN_ID" 800 500
```

You can also move and resize a window in one command with `wmctrl`:

```bash
	DISPLAY=:0 wmctrl -ir "$WIN_ID" -e 0,80,60,800,500
```

5. Check the exact coordinates, size, and map state of a window:

```bash
	DISPLAY=:0 xwininfo -id "$WIN_ID"
```

6. Close a window cleanly through the window manager:

```bash
	DISPLAY=:0 wmctrl -ic "$WIN_ID"
```

## Control the mouse and keyboard

Use `xdotool` to move the pointer, click, drag, and send keystrokes.

1. Read the current pointer coordinates and the window under the pointer:

```bash
	DISPLAY=:0 xdotool getmouselocation --shell
```

2. Move the pointer and click a mouse button. Button `1` is left click, `2` is middle click, `3` is right click, `4` is scroll up, and `5` is scroll down:

```bash
	DISPLAY=:0 xdotool mousemove --sync 300 250 click 1
```

3. Drag the pointer from one point to another:

```bash
	DISPLAY=:0 xdotool mousemove --sync 300 250 mousedown 1 mousemove --sync 500 250 mouseup 1
```

4. Type text or press key combinations in the focused window:

```bash
	DISPLAY=:0 xdotool type --delay 20 "echo 'hello world'"
	DISPLAY=:0 xdotool key Return
	DISPLAY=:0 xdotool key ctrl+shift+enter
```

## Capture screenshots with the mouse cursor visible

`maim` draws the XFixes mouse cursor in screenshots by default. Do not pass `-u` when you need to verify the pointer location. After you save a screenshot, inspect it with the `read` tool.

1. Capture the entire desktop with the mouse cursor visible:

```bash
	DISPLAY=:0 maim /tmp/opencode/desktop.png
```

2. Capture a specific window by its window ID with the mouse cursor visible:

```bash
	DISPLAY=:0 maim -i "$WIN_ID" /tmp/opencode/window.png
```

3. Capture a rectangular region of the screen:

```bash
	DISPLAY=:0 maim -g 800x500+80+60 /tmp/opencode/region.png
```

## Automate the Kitty terminal with Kitten

The user config at `~/.config/kitty/kitty.conf` sets two options that affect automation:

- `initial_window_width 120c` and `initial_window_height 40c` open `kitty` at `1227x1067`, which extends past the bottom of the `1280x800` screen. Resize `kitty` after launch so the whole terminal is visible.
- `hide_window_decorations yes` removes the titlebar. Move `kitty` with `xdotool windowmove` or `wmctrl -ir` instead of dragging a titlebar.

Remote control is off by default in `~/.config/kitty/kitty.conf`. To drive `kitty` with `kitten @`, enable remote control and bind a UNIX socket when you start `kitty`:

```bash
	export DISPLAY=:0
	rm -f /tmp/opencode/kitty.sock
	nohup kitty -o allow_remote_control=yes --listen-on unix:/tmp/opencode/kitty.sock >/dev/null 2>&1 &
	KITTY_PID=$!
	for i in {1..30}; do
		WIN_ID=$(xdotool search --onlyvisible --pid "$KITTY_PID" 2>/dev/null | head -n1)
		[ -n "$WIN_ID" ] && [ -S /tmp/opencode/kitty.sock ] && break
		sleep 0.1
	done
	wmctrl -ir "$WIN_ID" -e 0,240,90,850,520
	kitten @ --to unix:/tmp/opencode/kitty.sock set-tab-title "Work"
	kitten @ --to unix:/tmp/opencode/kitty.sock set-colors background=#1a1b26 foreground=#c0caf5
	kitten @ --to unix:/tmp/opencode/kitty.sock launch --location=vsplit --cwd=current
	kitten @ --to unix:/tmp/opencode/kitty.sock send-text "ls -la\r"
```
