# Takedawn

Build with `nix build .#takedawn`, but Takedawn ships no game data: the build
translates `default.xbe` from your own Burnout 3 disc into C, so a disc is
required. Extract it from a supported retail image and override the package:

```sh
nix build --impure --expr \
  'with import ./. { }; takedawn.override { defaultXbe = /path/to/default.xbe; }'
```

`region = "PAL"` or `"PAL-ENSV"` builds one of the European discs instead of
the default North America (`NTSC-U`) one. The result is `bin/takedawn`; the
game data itself is installed from your disc image on first start
(`takedawn --install /path/to/image.iso`, or the setup window of a release
build, which this source build does not carry).

The recompiler and runtime come from `xenophobentx/xboxrecomp` at the
matching `takedawn-<version>` tag, which is why `version` and the toolkit pin
move together. Regenerating the translated code needs `capstone` for the
toolkit's Python stages, and the button-prompt artwork needs `resvg`; both are
build inputs.
