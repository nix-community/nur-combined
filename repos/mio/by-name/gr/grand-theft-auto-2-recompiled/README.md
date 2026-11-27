# Grand Theft Auto 2 Recompiled

`nix build .#grand-theft-auto-2-recompiled` builds the native launcher,
runtime and winrecomp lifter from source. The package contains no GTA 2
code or data.

On first start, `gta2-launcher` asks for the 2004 Rockstar freeware release
(`GTA2.exe`) or an installed copy of it. It extracts the game files, lifts
`gta2.exe` and `binkw32.dll` to C with the bundled winrecomp toolkit, and
compiles the result with the compiler from the package closure. State
(`game/`, `saves/`, `data/`, `media/`, `shader/`) is written to
`$XDG_DATA_HOME/gta2-recompiled` (default `~/.local/share/gta2-recompiled`).
Set `GTA2_RECOMP_DATA_DIR` to use another directory.
