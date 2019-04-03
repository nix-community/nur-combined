{ pkgs }:

{
  gitignore = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "siers";
    repo = "nix-gitignore";
    rev = "4f2d85f2f1aa4c6bff2d9fcfd3caad443f35476e";
    sha256 = "1vzfi3i3fpl8wqs1yq95jzdi6cpaby80n8xwnwa8h2jvcw3j7kdz";
  }) { };

  utf8 = import ./utf-8;

  edn = import ./edn;
}

