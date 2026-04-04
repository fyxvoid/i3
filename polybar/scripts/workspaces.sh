#!/usr/bin/env bash
# Always render workspaces 1-5; expand if more are open

WS_JSON=$(i3-msg -t get_workspaces 2>/dev/null)

MAX=$(echo "$WS_JSON" | python3 -c "
import json,sys
ws=json.load(sys.stdin)
nums=[w['num'] for w in ws if w['num']>0]
print(max(nums) if nums else 1)
" 2>/dev/null)
[ "$MAX" -lt 5 ] 2>/dev/null && MAX=5

output=""
for i in $(seq 1 "$MAX"); do
    case $i in
        1) ic="" ;;
        2) ic="" ;;
        3) ic="" ;;
        4) ic="" ;;
        5) ic="" ;;
        *) ic="" ;;
    esac

    state=$(echo "$WS_JSON" | python3 -c "
import json,sys
ws=json.load(sys.stdin)
match=[w for w in ws if w['num']==$i]
if not match: print('empty')
elif match[0]['focused']: print('focused')
elif match[0]['urgent']: print('urgent')
else: print('occupied')
" 2>/dev/null || echo "empty")

    case $state in
        focused)
            fmt="%{F#1C2B35}%{B#E87DA0}%{u#E87DA0}%{+u} $ic %{-u}%{B-}%{F-}"
            ;;
        occupied)
            fmt="%{F#D8EEF8}%{B#2E4A62}%{u#5BBAD6}%{+u} $ic %{-u}%{B-}%{F-}"
            ;;
        urgent)
            fmt="%{F#1C2B35}%{B#E85868}%{u#E85868}%{+u} $ic %{-u}%{B-}%{F-}"
            ;;
        empty)
            fmt="%{F#4A7080} $ic %{F-}"
            ;;
    esac

    output+="%{A1:i3-msg workspace number $i:}${fmt}%{A}"
done

echo "$output"
