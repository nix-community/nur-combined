{
  callPackage,
  fetchFromGitHub,
}:
(callPackage ./generic.nix {
  pname = "liboqs";
  version = "0.16.0";
  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "liboqs";
    tag = "0.16.0";
    hash = "sha256-ys1ZqkcBFqblmYjTgDVYcdyK9PW2cvpPfaivbLTJZEU=";
  };
})
