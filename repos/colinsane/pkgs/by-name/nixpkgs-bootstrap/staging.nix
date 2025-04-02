{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "cea056bb0131e1dd456504736988537772a6570c";
  sha256 = "sha256-aKqH6gSp4lth7rUxd+Zdgvgo+4Y9KqtLy53kydlXpfI=";
  version = "0-unstable-2025-03-31";
  branch = "staging";
}
