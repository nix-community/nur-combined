{ callPackage, fetchFromGitHub, iortcw_sp, libjpeg_original }:

iortcw_sp.overrideAttrs (oldAttrs: rec {
  pname = "RealRTCW";
  version = "3.1n";

  src = fetchFromGitHub {
    owner = "wolfetplayer";
    repo = "realrtcw";
    rev = version;
    sha256 = "15aycfi2i9c6403hbm7jy05hgm2m6ci6059djvaz8w01jwrxih7l";
  };

  sourceRoot = "source";

  hardeningDisable = [ "format" ];

  buildInputs = [ libjpeg_original ] ++ oldAttrs.buildInputs;

  meta = oldAttrs.meta // {
    description = "RealRTCW mod based on ioRTCW engine";
    homepage = src.meta.homepage;
    broken = true;
  };
})
