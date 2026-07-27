{
  sources,

  lib,
  stdenv,

  libx11,
  libxcrypt,
  libxext,
  libxrandr,
}:
stdenv.mkDerivation {
  inherit (sources.slock-flexipatch) pname src;
  version = sources.slock-flexipatch.date;

  buildInputs = [
    libx11
    libxcrypt
    libxext
    libxrandr
  ];

  installFlags = [ "PREFIX=$(out)" ];

  postPatch = "sed -i '/chmod u+s/d' Makefile";

  enableParallelBuilding = true;

  makeFlags = [ "CC:=$(CC)" ];

  meta = {
    description = "An slock build with preprocessor directives to decide which patches to include during build time";
    homepage = "https://github.com/bakkeby/slock-flexipatch";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "slock";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
