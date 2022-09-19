with import <nixpkgs> {};
import <nur/lib/evalRepo.nix> {
  name = "arc";
  url = "{repo.url}";
  src = "${toString ../.}/nur.nix";
  inherit pkgs lib;
}
