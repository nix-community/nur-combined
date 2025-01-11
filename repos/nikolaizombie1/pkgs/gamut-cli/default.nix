{ buildGoModule, fetchFromGitHub, lib }:
{
  gamut-cli = buildGoModule rec {
    pname = "gamut-cli";
    version = "0.9.0";

    src = fetchFromGitHub {
      owner = "nikolaizombie1";
      repo = "gamut-cli";
      tag = "v${version}";
      hash = "sha256-ayBpx9GRE0pkVl8Zo9clsEoW+3Gwd7ynl5Ov1XO8q1I=";
    };

    vendorHash = "sha256-2KtQpzgz6xTupbejkm95OVxnamZmBwanPmzUkjzkB+o=";

    meta = {
      description = "A command line interface for the gamut library made by muesli.";
      homepage = "https://github.com/nikolaizombie1/gamut-cli";
      license = lib.licenses.gpl3Plus;
    };
  };
}
