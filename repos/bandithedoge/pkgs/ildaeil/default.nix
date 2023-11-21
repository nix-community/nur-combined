{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.ildaeil) pname src;
  version = sources.ildaeil.date;

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    libGL
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
  ];

  prePatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  makeFlags = ["PREFIX=$(out)"];

  meta = with pkgs.lib; {
    description = "mini-plugin host as plugin";
    homepage = "https://github.com/DISTRHO/Ildaeil";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
