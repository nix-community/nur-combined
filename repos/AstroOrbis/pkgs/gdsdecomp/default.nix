{
  lib,
  pkgs,
  stdenv,
  ...
}:
stdenv.mkDerivation rec {
  pname = "gdsdecomp";
  version = "v1.0.2";

  # the zip contains (gdre_tools.pck, gdre_tools.x86_64)
  src = pkgs.fetchzip {
    url = "https://github.com/GDRETools/gdsdecomp/releases/download/${version}/GDRE_tools-${version}-linux.zip";
    hash = "sha256-Ecyy/izBw6mXAk/jgsmDrzNr4OjamPjyGnu1dmyqO8k=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/bin
    mv gdre_tools.x86_64 $out/bin/gdre_tools
    mv gdre_tools.pck $out/bin/gdre_tools.pck
    chmod a+x $out/bin/gdre_tools
  '';

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  buildInputs =
    with pkgs;
    with xorg;
    [
      libX11
      libxcb
      libXrandr
      libXinerama
      libXcursor
      libXi
      libXxf86vm
    ];

}
