{ callPackage, fetchFromGitHub, iortcw_sp }:

iortcw_sp.overrideAttrs (oldAttrs: rec {
  pname = "realrtcw";
  version = "3.1n";

  src = fetchFromGitHub {
    owner = "wolfetplayer";
    repo = "realrtcw";
    rev = version;
    sha256 = "15aycfi2i9c6403hbm7jy05hgm2m6ci6059djvaz8w01jwrxih7l";
  };

  sourceRoot = "source";

  hardeningDisable = [ "format" ];

  meta = oldAttrs.meta // {
    description = "RealRTCW mod based on ioRTCW engine";
    homepage = src.meta.homepage;
  };
})
