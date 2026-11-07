# OMO agent settings (reference copy)

`settings/omo/agent/settings.json` records the stable Pi-family preferences that the live `~/.config/opencode/.omo/agent/settings.json` should keep: `theme` and the `packages` list (`omniroute-pi-ext-integration`, `pi-subagents`). Nothing applies this directory. `agent-ctrl apply` has no `omo` platform, and `apply pi` no longer reads a settings file from this repository.

The live file also holds session-local state: `lastChangelogVersion`, `changelogSeen`, `tipsHistory`, `tuiMode`, `defaultProvider`, `defaultModel`, `favoriteModels`, `modelThinkingLevels`, and `modelLastOnThinkingLevels`. Never copy the reference over it. To reconcile the two, compare the `theme` and `packages` keys by hand and leave every other key untouched.

See `../README.md` for how the rest of `settings/omo/` reaches the live directory.
