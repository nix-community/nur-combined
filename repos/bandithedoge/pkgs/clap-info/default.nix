{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.clap-info) pname version src;

  nativeBuildInputs = with pkgs; [
    cmake
  ];

  postPatch = ''
    substituteInPlace libs/clap/clap.pc.in \
      --replace '$'"{prefix}/@CMAKE_INSTALL_INCLUDEDIR@" '@CMAKE_INSTALL_FULL_INCLUDEDIR@'
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp clap-info $out/bin
  '';

  meta = with pkgs.lib; {
    description = "A tool to show information about a CLAP plugin on the command line";
    homepage = "https://github.com/free-audio/clap-info";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
