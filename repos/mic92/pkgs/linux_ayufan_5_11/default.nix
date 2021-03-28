{ stdenv, buildLinux, fetchFromGitHub, ... } @ args:

buildLinux (args // rec {
  version = "5.11.0-rc4-1147-ayufan";
  modDirVersion = "5.11.0";

  src = fetchFromGitHub {
    owner = "ayufan-rock64";
    repo = "linux-mainline-kernel";
    rev = version;
    sha256 = "sha256-GJneuZrgQU28/pOGU5VY5VJx+cm+8BAdnXGiOzvca00=";
  };
  extraMeta.platforms = [ "aarch64-linux" ];
  extraMeta.branch = "5.11";
} // (args.argsOverride or { }))
