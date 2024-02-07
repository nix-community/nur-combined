{ fetchFromGitHub }:

_final: prev: {
  gruvbox-nvim = prev.gruvbox-nvim.overrideAttrs (_: {
    version = "2024-01-29";

    src = fetchFromGitHub {
      owner = "ellisonleao";
      repo = "gruvbox.nvim";
      rev = "6e4027ae957cddf7b193adfaec4a8f9e03b4555f";
      sha256 = "sha256-jWnrRy/PT7D0UcPGL+XTbKHWvS0ixvbyqPtTzG9HY84=";
    };
  });
}
