{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.hera) pname src;
  version = sources.hera.date;

  nativeBuildInputs = [ juceCmakeHook ];

  meta = {
    description = "Juno 60 emulation synthesizer";
    homepage = "https://github.com/jpcima/Hera";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
