# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  fasttext-langid = pkgs.callPackage ./pkgs/fasttext-langid { };

  fasttext-langid-fetchurl-chunks = lib.fetchurlChunked {
    url = "https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin";

    # Produce hash list by calling:
    # ./lib/nix-prefetch-urlchunked.sh https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin
    #
    # chunksize: the default size used in nix-prefetch-urlchunked.sh
    chunksize = 1024 * 1024 * 32;
    hashes = [
      "a2756a326e365c336ff408efa5b40d804451b78381410eedff24d20f6924ef6c"
      "c057ea24dc859cd2abd9b10d4bcc55d6510f8ef93616631fc042ea1cc051ab4e"
      "625a61852ea69025956ebc9978607e29959c09d8280c17422dc722015c6c6a1c"
      "f8f8f672fa17c32382610319c9c5c7c1ab2a87ad8212e63c27530e01d72809cb"
    ];
  };

  # Example showing how to join existing chunked derivation
  fast-chunk-join = lib.joinDrv fasttext-langid-fetchurl-chunks {
    outputHashAlgo = "sha256";
    outputHash = "7e69ec5451bc261cc7844e49e4792a85d7f09c06789ec800fc4a44aec362764e";
  };

  # Example showing how to split and rejoin existing derivation
  fast-chunk = lib.splitFile fasttext-langid 10;
  fast-join = lib.joinDrv fast-chunk {
    outputHashAlgo = "sha256";
    outputHash = "7e69ec5451bc261cc7844e49e4792a85d7f09c06789ec800fc4a44aec362764e";
  };

  hello-chunk = lib.splitDir pkgs.hello 10;
  hello-join = lib.joinDrv hello-chunk {};
}

