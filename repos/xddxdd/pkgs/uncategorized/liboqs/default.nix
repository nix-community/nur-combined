{
  callPackage,
  fetchFromGitHub,
}:
let
  version = "0.16.0";
in
callPackage ./generic.nix {
  pname = "liboqs";
  inherit version;
  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "liboqs";
    tag = version;
    hash = "sha256-ys1ZqkcBFqblmYjTgDVYcdyK9PW2cvpPfaivbLTJZEU=";
  };
}
