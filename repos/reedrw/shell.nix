with import <nixpkgs> {};

let
  
nix-update-master = pkgs.fetchFromGitHub {
  owner = "Mic92";
  repo = "nix-update";
  rev = "04a051c4f91781c27003228e8a16592c730ba5f1";
  sha256 = "18snrx829wcnddivbzxp9qvdfwxpbd9pw89xafhdynv2c8pmvs6y";
};

in
pkgs.mkShell {

  buildInputs = [
    (import nix-update-master {})
    pkgs.nix-prefetch-github
  ];

}


