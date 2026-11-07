#!/bin/bash
i=$(cat)
j() { jq -r "$1 // empty" <<<"$i"; }
d=$(j '.workspace.current_dir // .cwd')
[ "$d" = "$HOME" ] && n="~" || n=${d##*/}
b=$(git -C "$d" --no-optional-locks branch --show-current 2>/dev/null)
m=$(j .model.display_name)
c=$(j .context_window.used_percentage); c=${c%.*}; c=${c:-0}
h=$(j .rate_limits.five_hour.used_percentage); h=${h%.*}
w=$(j .rate_limits.seven_day.used_percentage); w=${w%.*}
TEXT='205;214;244' OK='166;173;200' WARN='249;226;175' HOT='243;139;168'
C1='88;91;112' C2='69;71;90' C3='49;50;68' C4='24;24;37' C5='17;17;27'
fg() { local col=$OK; (( $1 >= 50 )) && col=$WARN; (( $1 >= 80 )) && col=$HOT; printf '\e[38;2;%sm' "$col"; }
fit() { if (( ${#1} <= $2 )); then printf %s "$1"; elif (( $2 >= 6 )); then printf '%s…' "${1:0:$(($2 - 1))}"; fi; }
for ((k = 0; k < 5; k++)); do ((k < c / 20)) && bar+=▰ || bar+=▱; done
ctx="󰍛 $(fg "$c")$bar  $c%"; cw=$((10 + ${#c}))
u= uw=0
[ -n "$h" ] && u+="$(fg "$h")󰔟 5h $h%" && uw=$((6 + ${#h}))
[ -n "$w" ] && u+="${u:+  }$(fg "$w")󰃭 wk $w%" && uw=$((uw + (uw ? 2 : 0) + 6 + ${#w}))
room=$((${COLUMNS:-200} - 4 - 2 - (cw + 2)))
[ -n "$u" ] && room=$((room - uw - 3))
(( room >= ${#m} + 5 )) && room=$((room - ${#m} - 5)) || m=
n=$(fit "$n" $((room - 5))); [ -n "$n" ] && room=$((room - ${#n} - 5))
[ -n "$b" ] && b=$(fit "$b" $((room - 5)))
p=
seg() { [ -n "$p" ] && printf '\e[38;2;%s;48;2;%sm' "$p" "$1" || printf '\e[38;2;%sm' "$1"; printf '\e[38;2;%s;48;2;%sm %s ' "$TEXT" "$1" "$2"; p=$1; }
[ -n "$m" ] && seg "$C1" "󰚩 $m"
[ -n "$n" ] && seg "$C2" " $n"
[ -n "$b" ] && seg "$C3" " $b"
seg "$C4" "$ctx"
[ -n "$u" ] && seg "$C5" $'\e]8;;https://claude.ai/settings/usage\a'"$u"$'\e]8;;\a'
printf '\e[0;38;2;%sm\e[0m\n' "$p"
