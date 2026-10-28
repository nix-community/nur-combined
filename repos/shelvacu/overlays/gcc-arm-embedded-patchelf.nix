# patchelf >=0.18 produces segfaulting binaries here unless --no-sort is given
final: prev:
prev.lib.genAttrs [ "gcc-arm-embedded-13" "gcc-arm-embedded-14" "gcc-arm-embedded-15" ] (
  name:
  prev.${name}.overrideAttrs (old: {
    preFixup =
      builtins.replaceStrings [ "patchelf --set-" ] [ "patchelf --no-sort --set-" ]
        old.preFixup;
  })
)
