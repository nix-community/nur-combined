with import <nixpkgs> {};

let

nix-prefetch-fixed = pkgs.nix-prefetch.overrideAttrs (
  old: rec {
    src = pkgs.fetchFromGitHub {
      owner = "msteen";
      repo = "nix-prefetch";
      rev = "6bda3ef3862173b3dabff3c2668add795f982572";
      sha256 = "1qw7ifc4syh8xprfcnj4kc7brx4x7bd0584sskgc1b3cpjnq5qs2";
    };
    patches = [];
  }
);

nix-update-fixed = pkgs.nix-update.overrideAttrs (
  old: rec {
    makeWrapperArgs = [
      "--prefix" "PATH" ":" (lib.makeBinPath [nix nix-prefetch-fixed])
    ];
  }
);


in
pkgs.mkShell {

  buildInputs = [
    nix-update-fixed
    nix-prefetch-fixed
    pkgs.nix-prefetch-github
  ];

}


