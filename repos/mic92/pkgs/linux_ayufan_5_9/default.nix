{ stdenv, buildLinux, fetchFromGitHub, ... } @ args:

buildLinux (args // rec {
  version = "5.9.0-1146-ayufan";
  modDirVersion = "5.9.0";

  src = fetchFromGitHub {
    owner = "ayufan-rock64";
    repo = "linux-mainline-kernel";
    rev = version;
    sha256 = "sha256-GJneuZrgQU28/pOGU5VY5VJx+cm+8BAdnXGiOzvcaI0=";
  };
  extraMeta.platforms = [ "aarch64-linux" ];
  extraMeta.branch = "5.9";
} // (args.argsOverride or { }))
