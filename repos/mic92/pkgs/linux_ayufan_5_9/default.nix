{ stdenv, buildLinux, fetchFromGitHub, ... } @ args:

buildLinux (args // rec {
  version = "5.9.0-1145-ayufan";
  modDirVersion = "5.9.0";

  src = fetchFromGitHub {
    owner = "ayufan-rock64";
    repo = "linux-mainline-kernel";
    rev = version;
    sha256 = "sha256-EwlGzFuZT7M5RgUYgz8o8NEJsFlkVP5UVaXi/K/tjNE=";
  };
  extraMeta.platforms = [ "aarch64-linux" ];
  extraMeta.branch = "5.9";
} // (args.argsOverride or { }))
