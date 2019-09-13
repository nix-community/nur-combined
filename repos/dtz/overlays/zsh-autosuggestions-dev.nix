self: super: {
  zsh-autosuggestions-dev = super.zsh-autosuggestions.overrideAttrs (o: rec {
    name = "zsh-autosuggestions-${version}";
    version = "0.5.0-git";
    src = super.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-autosuggestions";
#      rev = "v${version}";
      rev = "161de32912a3426dc686db38250913227dd91948"; # redraw-hook
      sha256 = "1r2gf26nd28ypcj83xzhy63ql4c3jcr7v8nr529jn406ssdw68dw";
    };
  });
}
