{
  fetchFromGitHub,
  pkgs,
  lib,
}:
let
  rustPlatform = pkgs.makeRustPlatform { inherit (pkgs.fenix.minimal) cargo rustc; };
in

rustPlatform.buildRustPackage rec {
  pname = "trojan-rs";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "lazytiger";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-SeDhOUMyL59r1pLUxI5M9T1ZR1jBNYRph72bx1k3n7E=";
  };

  cargoHash = "sha256-eAVc80S1V3RbywOmR8h+GFexhdDDAAKlyXI6kSoL5Vg=";

  meta = with lib; {
    homepage = "https://github.com/lazytiger/trojan-rs";
    description = "Trojan server and proxy programs written in Rust";
    license = licenses.mit;
    mainProgram = "trojan";
    maintainers = with maintainers; [ oluceps ];
  };
}
