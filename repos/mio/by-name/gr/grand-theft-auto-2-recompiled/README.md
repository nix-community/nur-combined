# Grand Theft Auto 2 Recompiled

`nix build .#grand-theft-auto-2-recompiled` builds the native launcher,
runtime and winrecomp lifter from source. The package contains no GTA 2
code or data.

On first start, `gta2-launcher` asks for the 2004 Rockstar freeware installer
(`GTA2INSTALLER.exe`, about 362 MB) or an installed copy of it. The installer
is available from the Internet Archive's
[Grand Theft Auto 2 (Rockstar Freeware)](https://archive.org/details/gta2_rockstar-classics)
item:

```sh
curl -fL --retry 3 -o GTA2INSTALLER.exe \
  https://archive.org/download/gta2_rockstar-classics/GTA2INSTALLER.exe
sha256sum GTA2INSTALLER.exe
```

The SHA-256 checksum is
`0cd380498dfbe62448d56aaddd3e36593cfda324aa8a3972b06a02d015b083a0`.

The launcher extracts the game files, lifts `gta2.exe` and `binkw32.dll` to C
with the bundled winrecomp toolkit, and compiles the result with the compiler
from the package closure. State (`game/`, `saves/`, `data/`, `media/`,
`shader/`) is written to `$XDG_DATA_HOME/gta2-recompiled` (default
`~/.local/share/gta2-recompiled`). Set `GTA2_RECOMP_DATA_DIR` to use another
directory.
