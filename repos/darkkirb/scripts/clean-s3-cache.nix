{
  python3,
  boto3,
  stdenvNoCC,
  lib,
}: let
  clean-s3-cache-env = python3.buildEnv.override {
    extraLibs = [boto3];
  };
in
  stdenvNoCC.mkDerivation {
    name = "clean-s3-cache";
    src = ./clean-s3-cache.py;
    python = clean-s3-cache-env;
    unpackPhase = ''
      cp $src clean-s3-cache.py
    '';
    buildPhase = ''
      substituteAllInPlace clean-s3-cache.py
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp clean-s3-cache.py $out/bin
      chmod +x $out/bin/clean-s3-cache.py
    '';
    meta = {
      description = "Scriept for cleaning a nix s3 binary cache";
      license = lib.licenses.bsd2;
    };
  }
