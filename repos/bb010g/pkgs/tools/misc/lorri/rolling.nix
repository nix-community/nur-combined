{ callPackage, lib, fetchFromGitHub, ... } @ args:

let
  generic = import ./generic.nix;
  genericArgs = lib.attrNames (lib.functionArgs generic);
  oArgs = lib.filterAttrs (a: _: lib.elem a genericArgs) args;
in (callPackage generic ({
  version = "2019-03-28";

  # rolling-release branch
  src = fetchFromGitHub {
    owner = "target";
    repo = "lorri";
    rev = "094a903d19eb652a79ad6e7db6ad1ee9ad78d26c";
    sha256 = "0y9y7r16ki74fn0xavjva129vwdhqi3djnqbqjwjkn045i4z78c8";
  };

  cargoSha256 = "0lx4r05hf3snby5mky7drbnp006dzsg9ypsi4ni5wfl0hffx3a8g";
} // oArgs)).overrideAttrs (o: {
  preCheck = ''
    source ${o.src + "/nix/pre-check.sh"}
  '';
})
