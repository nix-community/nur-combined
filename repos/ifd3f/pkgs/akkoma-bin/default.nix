# https://docs.akkoma.dev/stable/installation/otp_en/#installing-akkoma
{ lib, fetchzip, system, stdenvNoCC, version ? "2022.08"
, sha256 ? "sha256-dVnbhOAl7DWgQ+Otr27LBBh9PHFHl9JJYNSizV2VXaA=" }:
stdenvNoCC.mkDerivation rec {
  inherit version;
  pname = "akkoma-bin";
  src = fetchzip {
    inherit sha256;
    url = let flavour = "amd64-musl"; # use musl to disable dynamic linking
    in "https://akkoma-updates.s3-website.fr-par.scw.cloud/${version}/akkoma-${flavour}.zip";
  };
  phases = [ "installPhase" ];

  installPhase = ''
    cp -r "$src" "$out/"
    chmod 755 $out/bin/*
  '';

  dontPatchELF = true;
  meta = with lib; {
    description = "Akkoma";
    homepage = "https://akkoma.dev/";
    license = licenses.agpl3Only;
    mainProgram = "pleroma";
    platforms = [ "x86_64-linux" ];
  };
}
