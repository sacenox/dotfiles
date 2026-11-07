#!/usr/bin/env bash
# Claude Code status line: context, cwd, git, and 5-hour and weekly plan usage.
#
# Hierarchy comes from weight, not hue. Claude Code paints the line in its own
# grey and ignores SGR 39, so the terminal's default fg can't be requested.
# Bright white is the nearest match on dark themes; change FG for a light one.

export LC_ALL=C.UTF-8

ESC=$'\e'
RESET="$ESC[0m" DIM="$ESC[2m"
FG="$ESC[97m"
STRONG="$ESC[1m$FG"
INVERT="$ESC[1;7m$FG"

# Octicons from Nerd Fonts; these codepoints are the same in v2 and v3.
ICON_CONTEXT=$''   # cpu
ICON_DIR=$''       # file_directory
ICON_BRANCH=$''    # git_branch
ICON_DETACHED=$''  # git_commit
ICON_CLEAN=$''     # check
ICON_USAGE=$''     # dashboard
ICON_TIME=$''      # clock

WARN_AT=80 # at or above this percentage a value flips to reverse video
GAP='   '

settings="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
[[ -r $settings ]] || settings=/dev/null

# Context is measured against the auto-compact window when one is configured,
# so 100% means "about to compact". used_percentage is relative to the full
# model window, which would read 30% at compaction with a 300k limit on 1M.
IFS=$'\x1f' read -r ctx cwd used_5h resets_5h used_7d resets_7d < <(
  jq -r --rawfile cfg "$settings" '
    def pct: if . == null then "" else round end;
    def epoch: if . == null then "" else floor end;
    (try ($cfg | fromjson) catch {}) as $s
    | (.model.id // "") as $id
    | ($s.modelSettings[$id].autoCompactWindow
        // $s.modelSettings[$id | sub("\\[.*$"; "")].autoCompactWindow
        // $s.autoCompactWindow) as $limit
    | .context_window as $c
    | [ (if $c.used_percentage == null then ""
         elif $limit != null and $c.total_input_tokens != null
              and $limit < ($c.context_window_size // 0)
         then $c.total_input_tokens / $limit * 100 | round
         else $c.used_percentage | round end),
        (.workspace.current_dir // .cwd // ""),
        (.rate_limits.five_hour.used_percentage | pct),
        (.rate_limits.five_hour.resets_at | epoch),
        (.rate_limits.seven_day.used_percentage | pct),
        (.rate_limits.seven_day.resets_at | epoch)
      ] | map(tostring) | join("\u001f")'
)
[[ -n $cwd ]] || cwd=$PWD

# Glyphs paint two cells: the trailing space carries the dim for the second half.
icon()  { printf '%s%s %s ' "$DIM" "$1" "$RESET"; }
level() { # level <pct>: the value, reversed once it crosses WARN_AT
  if (( $1 >= WARN_AT )); then
    printf '%s %s%% %s' "$INVERT" "$1" "$RESET"
  else
    printf '%s%s%%%s' "$STRONG" "$1" "$RESET"
  fi
}
duration() { # duration <seconds>: the two largest units
  local s=$1
  if   (( s >= 86400 )); then printf '%dd%02dh' $(( s / 86400 )) $(( s % 86400 / 3600 ))
  elif (( s >= 3600 ));  then printf '%dh%02dm' $(( s / 3600 )) $(( s % 3600 / 60 ))
  elif (( s >= 60 ));    then printf '%dm' $(( s / 60 ))
  else printf '<1m'
  fi
}
window() { # window <label> <pct> <resets_at>: absent until the first API response
  [[ -n $2 ]] || return 0
  local seg left
  seg="$(icon "$ICON_USAGE")$DIM$1$RESET $(level "$2")"
  left=$(( ${3:-0} - EPOCHSECONDS ))
  (( left > 0 )) && seg+=" $(icon "$ICON_TIME")$(duration "$left")"
  segments+=("$seg")
}

segments=()

# Context
[[ -n $ctx ]] && segments+=("$(icon "$ICON_CONTEXT")$(level "$ctx")")

# Working directory: ~ for home, at most the last two components below it
dir=$cwd
if [[ $dir == "$HOME" || $dir == "$HOME"/* ]]; then
  dir="~${dir#"$HOME"}"
fi
if [[ $dir =~ ^(~?)/.+/([^/]+/[^/]+)$ ]]; then
  dir="${BASH_REMATCH[1]}/…/${BASH_REMATCH[2]}"
fi
segments+=("$(icon "$ICON_DIR")$dir")

# Git: branch, ahead/behind and file counts from a single status call
read -r head detached staged modified untracked conflicts ahead behind < <(
  git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null | awk '
    $1 == "#" && $2 == "branch.oid"  { oid = $3 }
    $1 == "#" && $2 == "branch.head" { head = $3 }
    $1 == "#" && $2 == "branch.ab"   { ahead = substr($3, 2) + 0; behind = substr($4, 2) + 0 }
    $1 == "1" || $1 == "2" {
      if (substr($2, 1, 1) != ".") staged++
      if (substr($2, 2, 1) != ".") modified++
    }
    $1 == "u" { conflicts++ }
    $1 == "?" { untracked++ }
    END {
      if (head == "") exit
      detached = head == "(detached)"
      if (detached) head = substr(oid, 1, 7)
      print head, detached + 0, staged + 0, modified + 0, untracked + 0, conflicts + 0, ahead + 0, behind + 0
    }'
)
if [[ -n $head ]]; then
  branch_icon=$ICON_BRANCH
  (( detached )) && branch_icon=$ICON_DETACHED
  git_seg="$(icon "$branch_icon")$STRONG$head$RESET"

  summary=''
  (( conflicts )) && summary+=" !$conflicts"
  (( staged ))    && summary+=" +$staged"
  (( modified ))  && summary+=" ~$modified"
  (( untracked )) && summary+=" ?$untracked"
  (( ahead ))     && summary+=" ↑$ahead"
  (( behind ))    && summary+=" ↓$behind"
  [[ -n $summary ]] || summary=" $DIM$ICON_CLEAN $RESET"
  segments+=("$git_seg$summary")
fi

# Plan usage
window 5h "$used_5h" "$resets_5h"
window 7d "$used_7d" "$resets_7d"

out=''
for s in "${segments[@]}"; do
  out+="${out:+$GAP}$s"
done
printf '%s\n' "$out"
