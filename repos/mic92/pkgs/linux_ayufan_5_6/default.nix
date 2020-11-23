{ stdenv, buildLinux, fetchFromGitHub, ... } @ args:

buildLinux (args // rec {
  version = "5.6.0-1138-ayufan";
  modDirVersion = "5.6.0";

  src = fetchFromGitHub {
    owner = "ayufan-rock64";
    repo = "linux-mainline-kernel";
    rev = version;
    sha256 = "sha256-vmUHdTkR9OblNbMr8MP3STwThihoB0heJhp1q1CEdkI=";
  };
  extraMeta.platforms = [ "aarch64-linux" ];
  extraMeta.branch = "5.6";
} // (args.argsOverride or {}))
