#!/bin/sh
# Claude Code hook -> desktop notification that names the session.
# Usage (hook command): sh "$HOME/.claude/notify.sh" "<title>"   (hook JSON on stdin)
in=$(cat)

# Session name: undocumented ~/.claude/sessions/<claude-pid>.json, found by walking up the process tree.
p=$PPID; name=
while [ "${p:-0}" -gt 1 ]; do
  f="$HOME/.claude/sessions/$p.json"
  [ -f "$f" ] && { name=$(jq -r '.name // empty' "$f" 2>/dev/null); break; }
  p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
done

dir=$(printf %s "$in" | jq -r '.cwd // empty'); dir=${dir##*/}
sid=$(printf %s "$in" | jq -r '.session_id // empty' | cut -c1-6)
body=$(printf %s "$in" | jq -r '(.last_assistant_message // .message // "") | gsub("\\s+";" ") | .[0:140]')

${NOTIFY_CMD:-notify-send} -a "Claude Code" "$1 · ${name:-${dir:-?}} (${sid:-?})" "$body" 2>/dev/null
exit 0
