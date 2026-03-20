{
  lib,
  stdenv,
  sources,
  source ? sources.manpage-zh,

  cmake,
  python3,
  opencc,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "man-pages-zh";
  inherit (source) version src;

  nativeBuildInputs = [
    cmake
    python3
    opencc
  ];

  preBuild = ''
    patchShebangs ../utils
  '';

  cmaeFlags = with lib.strings; [
    (cmakeBool "ENABLE_APPEND_COLOPHON" false)
    (cmakeBool "ENABLE_ZHCN" true)
    (cmakeBool "ENABLE_ZHTW" true)
  ];

  meta = {
    description = "Chinese Manual Pages";
    homepage = "https://github.com/man-pages-zh/manpages-zh";
    license = lib.licenses.fdl12Plus;
    platform = lib.platforms.all;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
