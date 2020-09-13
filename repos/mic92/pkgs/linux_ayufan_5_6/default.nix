{ stdenv, buildLinux, fetchFromGitHub, ... } @ args:

buildLinux (args // rec {
  version = "5.6.0-1137-ayufan";
  modDirVersion = "5.6.0";

  src = fetchFromGitHub {
    owner = "ayufan-rock64";
    repo = "linux-mainline-kernel";
    rev = version;
    sha256 = "1ylw469d78cyhmbwyw3vpjaay400xlka7mj2xybg3w6iia6k1xam";
  };
  extraMeta.platforms = [ "aarch64-linux" ];
  extraMeta.branch = "5.6";
} // (args.argsOverride or {}))
