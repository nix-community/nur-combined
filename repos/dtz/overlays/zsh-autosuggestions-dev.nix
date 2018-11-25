self: super: {
  zsh-autosuggestions-dev = super.zsh-autosuggestions.overrideAttrs (o: rec {
    name = "zsh-autosuggestions-${version}";
    version = "0.5.0";
    src = super.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-autosuggestions";
      rev = "v${version}";
      sha256 = "19qkg4b2flvnp2l0cbkl4qbrnl8d3lym2mmh1mx9nmjd7b81r3pf";
    };
  });
}
