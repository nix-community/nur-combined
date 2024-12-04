{
  fetchurl,
  lib,
  stdenv,
  p7zip,
  rpmextract,
}:
stdenv.mkDerivation {
  pname = "red-star-os-wallpapers";
  version = "3.0";
  src = fetchurl {
    url = "https://archive.org/download/RedStarOS/Red%20Star%20OS%203.0%20Desktop/DESKTOP_redstar_desktop3.0_sign.iso";
    hash = "sha256-iVrQ4Brg01pl6axC3TTQodaF1t+jMc5bTyS7x1NDm+M=";
  };

  nativeBuildInputs = [
    p7zip
    rpmextract
  ];

  unpackPhase = ''
    runHook preUnpack

    7z x $src RedStar/RPMS/desktop-backgrounds-basic-2.0-31.rs3.0.noarch.rpm
    rpmextract RedStar/RPMS/desktop-backgrounds-basic-2.0-31.rs3.0.noarch.rpm

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/share $out/share

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Wallpapers from DPRK Red Star OS 3.0";
    homepage = "https://archive.org/details/RedStarOS";
    license = lib.licenses.unfree;
  };
}
