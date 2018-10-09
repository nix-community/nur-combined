self: super: {
  nix-zsh-completions = super.nix-zsh-completions.overrideAttrs (o: rec {
    name = "nix-zsh-completions-${version}";
    version = "0.4.0.1"; # not really
    src = super.fetchFromGitHub {
      owner = "spwhitt";
      repo = "nix-zsh-completions";
      rev = "13a5533b231798c2c8e6831e00169f59d0c716b8";
      sha256 = "1xa1nis1pvns81im15igbn3xxb0mhhfnrj959pcnfdcq5r694isj";
    };
  });
}
