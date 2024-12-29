{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "e39a96633389958a895c04435a68de1d098787a7";
  sha256 = "sha256-z6U6iY8MnRU+DN7j70uPpy2ZIxXC7NGrIBQB3A2aRjQ=";
  version = "0-unstable-2024-12-29";
  branch = "staging-next";
}
