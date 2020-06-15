{ fetchFromGitHub, lib, zoxide }:

zoxide.overrideAttrs (drv: rec {
  version = "4b5f2e7";
  src = fetchFromGitHub {
    owner = "ajeetdsouza";
    repo = "zoxide";
    rev = "v${version}";
    sha256 = "1xbpsva7xy9sr5q600ij5y66yyhd27ca9zgz60p1a3b0qqiggdhn";
  };
  cargoDeps = drv.cargoDeps.overrideAttrs (lib.const {
    inherit src;
    outputHash = "16f6xb2cb4jfa1f11ybn9ibvmnw347id2pnpl7l4fj2jdqsj0fiz";
  });
})
