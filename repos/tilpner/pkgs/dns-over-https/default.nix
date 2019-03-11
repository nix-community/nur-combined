{ buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "dns-over-https";
  version = "2.0";

  goPackagePath = "github.com/m13253/${pname}";

  src = fetchFromGitHub {
    owner = "m13253";
    repo = pname;
    rev = "a400f03960c0c541203341e9aa8dbfe8dbeba506";
    sha256 = "0cbybfryjnnlbd4vijwhcrmk9h1mbnp0plf9cyxvsh2gvxv14q15";
  };

  goDeps = ./deps.nix;
}
