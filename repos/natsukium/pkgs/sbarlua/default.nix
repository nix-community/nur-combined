{
  source,
  lib,
  stdenv,
  readline,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "unstable-${source.date}";

  postPatch = ''
    substituteInPlace makefile \
      --replace "clang" "$CC"
  '';

  buildInputs = [ readline ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installFlags = [ "INSTALL_DIR=$(out)/bin" ];

  meta = with lib; {
    description = "A Lua API for SketchyBar";
    homepage = "https://github.com/FelixKratz/SbarLua";
    license = licenses.gpl3Only;
    # require mach.h
    platforms = platforms.darwin;
  };
}
