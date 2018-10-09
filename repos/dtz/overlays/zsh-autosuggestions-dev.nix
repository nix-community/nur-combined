self: super: {
  zsh-autosuggestions-dev = super.zsh-autosuggestions.overrideAttrs (o: rec {
    name = "zsh-autosuggestions-${version}";
    version = "0.4.3.1"; # not really
    src = super.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-autosuggestions";
      rev = "fa5d9c0ff5fb202545e12c98dae086d91d70ba50"; #"v${version}";
      sha256 = "0mk53kgvxbw8fxcj9l17jg0dmvibpq4pc5ylc7zjd6m62glik6nh";
    };
  });
}
