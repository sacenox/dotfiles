#!/bin/bash
i=$(cat)
j() { jq -r "$1 // empty" <<<"$i"; }
d=$(j '.workspace.current_dir // .cwd')
[ "$d" = "$HOME" ] && n="~" || n=${d##*/}
b=$(git -C "$d" --no-optional-locks branch --show-current 2>/dev/null)
c=$(j .context_window.used_percentage); c=${c%.*}; c=${c:-0}
h=$(j .rate_limits.five_hour.used_percentage); h=${h%.*}
w=$(j .rate_limits.seven_day.used_percentage); w=${w%.*}
fg() { printf '\e[38;5;%sm' $(( $1 < 50 ? 2 : $1 < 80 ? 3 : 1 )); }
for ((k = 0; k < 10; k++)); do ((k < c / 10)) && bar+=▰ || bar+=▱; done
p=
seg() { [ -n "$p" ] && printf '\e[38;5;%s;48;5;%sm' "$p" "$1"; printf '\e[38;5;0;48;5;%sm %s ' "$1" "$2"; p=$1; }
printf '\e[38;5;5m'
seg 5 $'\U000f06a9 '"$(j .model.display_name)"
seg 4 $' '"$n"
[ -n "$b" ] && seg 2 $' '"$b"
seg 8 "$(fg "$c")$bar $c%"
[ -n "$h$w" ] && seg 0 "$(fg "${h:-0}")"$'\U000f051f'" 5h ${h:-?}% $(fg "${w:-0}")"$'\U000f00ed'" 7d ${w:-?}%"
printf '\e[0;38;5;%sm\e[0m\n' "$p"
