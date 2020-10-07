with import <nixpkgs> {};

pkgs.mkShell rec {

  buildInputs = with pkgs; [
    nix-update
  ];

}


