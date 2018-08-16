self: super: {
  tmux = super.tmux.overrideAttrs (old: {
    name = "tmux-2.7";
    src = super.pkgs.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      rev = "2.7";
      sha256 = "1yr4l8ckd67c3id4vrbpha91xxpdfpw0cpbr3v81lam0m7k4rgba";
    };
  });
}
