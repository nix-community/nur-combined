{ pkgs, stdenv }:

let
  repo = pkgs.fetchFromGitHub {
    owner = "UCTRONICS";
    repo = "U6143_ssd1306";
    rev = "b6054912eb468c11704eef27862af25cd111d225";
    hash = "sha256-mKhwT9RNOvW2NAJCgWsffPKbrGWvqjRa4bq6lJEbhDY=";
  };
in stdenv.mkDerivation rec {
  pname = "U6143_ssd1306";
  version = "b605491";
  src = "${repo}/C";
  patches = [
    ./celsius.patch
    ./ifname.patch
  ];
  patchFlags = "-p2";
  installPhase = ''
    mkdir -p $out/bin
    install -t $out/bin display
  '';
}
