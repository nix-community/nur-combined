{ treefmt }:
{
  check-json.enable = true;
  check-yaml.enable = true;
  detect-private-keys.enable = true;
  end-of-file-fixer.enable = true;
  trim-trailing-whitespace.enable = true;
  nil.enable = true;
  shellcheck.enable = true;
  treefmt = {
    enable = true;
    package = treefmt.config.build.wrapper;
  };
}
