{ lib
, stdenvNoCC
, fetchurl
, unzip
, wine64
}:

stdenvNoCC.mkDerivation rec {
  pname = "qaac-bin";
  version = "2.82";

  src = fetchurl {
    url = "https://github.com/nu774/qaac/releases/download/v${version}/qaac_${version}.zip";
    hash = "sha256-9Zi+HMpzB6EKHSPcjoHeXBfSkwVwPs2g/+YtZIKPobQ=";
  };

  nativeBuildInputs = [
    unzip
  ];

  buildPhase = ''
    cat >qaac.sh <<EOF
    #!/bin/sh
    exec ${wine64}/bin/wine64 $out/opt/qaac/qaac64.exe "\$@"
    EOF
    chmod +x qaac.sh
  '';

  installPhase = ''
    mkdir -p $out/opt
    cp -r x64 $out/opt/qaac
    mkdir -p $out/bin
    cp qaac.sh $out/bin/qaac
  '';

  meta = with lib; {
    description = "CLI QuickTime AAC/ALAC encoder [binary build]";
    homepage = "https://github.com/nu774/qaac";
    # https://github.com/nu774/qaac/raw/master/COPYING
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "qaac";
    platforms = platforms.all;
  };
}
