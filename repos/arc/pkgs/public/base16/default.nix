{
  base16-schemes-source = import ./source.nix {
    pname = "base16-schemes-source";
    version = "2021-04-14";
    rev = "944dbc76180ddf3301289c59f143b8d6d37c1a9e";
    sha256 = "sha256-ptSYeEvaHJKCJyzIt15ITdtr5x84p01LVAAsL+WH+qo=";
    sources = ./schemes.json;
  };
  base16-templates-source = import ./source.nix {
    pname = "base16-templates-source";
    version = "2021-04-14";
    rev = "816b70a620664787cc74ac63354c5ec1f426bb81";
    sha256 = "sha256-PjznHgJHUWTZR22kiajigcDWvmzL0KcE8wdJ6sZHwAg=";
    sources = ./templates.json;
  };
  base16-schemes = import ./schemes.nix;
  # moved to build-support to avoid being considered a package
  #base16-templates = import ./templates.nix;
  #base16-shell-preview-arc = ./base16-shell-preview.nix;
}
