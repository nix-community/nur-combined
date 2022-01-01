{ pkgs  }:
pkgs.stdenv.mkDerivation {
  name = "qutebrowser-start-page-css";
  src = pkgs.fetchFromGitHub {
    rev = "1e7757a856ed5acd73bc1ea66d1073b255dac6fd";
    owner = "afreakk";
    repo = "qutebrowser-start-page";
    sha256 = "sha256-2egOtTFS5RpdFN5M0wqO3s5esvQ4EaB2Mgdvxn0b9yY=";
  };
  buildPhase = ''
    ${pkgs.nodePackages.tailwindcss}/bin/tailwindcss -i ./input.css -o ./output.css
  '';
  installPhase = ''
    mkdir -p $out/css
    cp output.css $out/css
  '';
}
