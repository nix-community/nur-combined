#!/usr/bin/env bash
# Start Claude Code with bypass mode available in the Shift+Tab cycle. A session still
# starts in auto mode (permissions.defaultMode in settings.json); bypass mode is one
# switch away when a task needs it.
exec claude --allow-dangerously-skip-permissions "$@"
