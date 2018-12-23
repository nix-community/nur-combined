self: super: {
  zsh-autosuggestions-dev = super.zsh-autosuggestions.overrideAttrs (o: rec {
    name = "zsh-autosuggestions-${version}";
    version = "0.5.0-git";
    src = super.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-autosuggestions";
#      rev = "v${version}";
      rev = "50579b33716f2b64251f6f192b2a89612c77caf8";
      sha256 = "0jzazjd4s7xk4ccwgz0fvjrr3jc3528dgvgi8r71sn2ifnp12879";
    };
  });
}
