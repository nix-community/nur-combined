{
  box64,
  pkgs,
}:
box64.overrideAttrs (prev: {
  nativeBuildInputs = [pkgs.mold];
  cmakeFlags =
    prev.cmakeFlags
    ++ [
      "-DSTATICBUILD"
      "-DWITH_MOLD=1"
    ];
})
