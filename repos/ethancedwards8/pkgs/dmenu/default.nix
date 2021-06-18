{ pkgs, fetchFromGitLab, ... }@inputs:

pkgs.dmenu.overrideAttrs (oldAttrs: rec {
  # src = inputs.dmenu;
  __contentAddressed = true;
  src = fetchFromGitLab {
    owner = "ethancedwards";
    repo = "dmenu-config";
    rev = "9cd6fe49998b48aa1b97e8b66d8895624b0ac897";
    sha256 = "Kqhf7+kl+izCyrcwW6LaNrbYFh23j1nmBN+7/ebOlA0=";
  };
})
