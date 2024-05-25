{ pkgs, ... }:
let
  img = pkgs.fetchurl {
    url = "https://maxwell.ydns.eu/git/rnhmjoj/nix-slim/raw/branch/master/background.png";
    name = "img.jpg";
    hash = "sha256-kqvVGHOaD7shJrvYfhLDvDs62r20wi8Sajth16Spsrk=";
  };
  img-blurred = pkgs.runCommand "img.jpg" {
    nativeBuildInputs = with pkgs; [ imagemagick ];
  } "convert -blur 14x5 ${img} $out";
in
''
  daemonize
  font=Hanken Grotesk
  image=${img-blurred}
  indicator-radius=100
  indicator-thickness=15
  inside-clear-color=563F2E00
  inside-color=00000000
  inside-ver-color=563F2E00
  inside-wrong-color=563F2E00
  key-hl-color=FFFFFB
  ring-clear-color=86A697
  ring-color=86A697
  ring-ver-color=FEDFE1
  ring-wrong-color=F17C67
  scaling=fill
  show-failed-attempts
  text-clear-color=FCFAF2
  text-ver-color=FEDFE1
  text-wrong-color=F17C67
''
