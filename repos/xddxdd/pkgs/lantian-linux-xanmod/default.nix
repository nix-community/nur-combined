{
  callPackage,
  lib,
  sources,
  ...
} @ args: let
  helpers = callPackage ./helpers.nix {};
  inherit (helpers) mkKernel;

  batch = {
    prefix,
    definitionDir,
    version,
    src,
    ...
  }: let
    prefix' =
      if prefix != ""
      then prefix + "-"
      else "";
  in [
    (lib.nameValuePair "${prefix'}generic" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
    }))
    (lib.nameValuePair "${prefix'}generic-lto" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
    }))
    (lib.nameValuePair "${prefix'}x86_64-v1" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
      lto = false;
      x86_64-march = "v1";
    }))
    (lib.nameValuePair "${prefix'}x86_64-v1-lto" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
      lto = true;
      x86_64-march = "v1";
    }))
    (lib.nameValuePair "${prefix'}x86_64-v2" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
      lto = false;
      x86_64-march = "v2";
    }))
    (lib.nameValuePair "${prefix'}x86_64-v2-lto" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
      lto = true;
      x86_64-march = "v2";
    }))
    (lib.nameValuePair "${prefix'}x86_64-v3" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
      lto = false;
      x86_64-march = "v3";
    }))
    (lib.nameValuePair "${prefix'}x86_64-v3-lto" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
      lto = true;
      x86_64-march = "v3";
    }))
    (lib.nameValuePair "${prefix'}x86_64-v4" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
      lto = false;
      x86_64-march = "v4";
    }))
    (lib.nameValuePair "${prefix'}x86_64-v4-lto" (mkKernel {
      inherit version src;
      configFile = definitionDir + "/config.nix";
      patchDir = definitionDir + "/patches";
      lto = true;
      x86_64-march = "v4";
    }))
  ];

  batches = (batch {
    prefix = "";
    definitionDir = ./latest;
    inherit (sources.linux-xanmod) version src;
  }) ++ (batch {
    prefix = "latest";
    definitionDir = ./latest;
    inherit (sources.linux-xanmod) version src;
  }) ++ (batch {
    prefix = "lts";
    definitionDir = ./v6_1;
    inherit (sources.linux-xanmod-6_1) version src;
  }) ++ (batch {
    prefix = "v6_1";
    definitionDir = ./v6_1;
    inherit (sources.linux-xanmod-6_1) version src;
  }) ++ (batch {
    prefix = "v6_0";
    definitionDir = ./v6_0;
    inherit (sources.linux-xanmod-6_0) version src;
  });
in
  builtins.listToAttrs batches
