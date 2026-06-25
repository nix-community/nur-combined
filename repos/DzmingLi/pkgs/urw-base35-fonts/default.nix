{ pkgs, stdenvNoCC, fetchFromGitHub, ... }:

stdenvNoCC.mkDerivation {
  pname = "urw-base35-fonts";
  version = "20200910";

  src = fetchFromGitHub {
    owner = "ArtifexSoftware";
    repo = "urw-base35-fonts";
    rev = "20200910";
    hash = "sha256-YQl5IDtodcbTV3D6vtJi7CwxVtHHl58fG6qCAoSaP4U=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/opentype fonts/*.otf
    install -Dm644 -t $out/share/fonts/truetype fonts/*.ttf
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "URW++ Base 35 Fonts — Nimbus Sans, Nimbus Roman, Nimbus Mono PS, etc. (OTF/TTF). Visual match for the Type 1 NimbusSanL / NimbusRomNo9L / NimbusMonL fonts that TeX/cvpr.sty embeds.";
    homepage = "https://github.com/ArtifexSoftware/urw-base35-fonts";
    license = licenses.agpl3Only;
    platforms = platforms.all;
  };
}
