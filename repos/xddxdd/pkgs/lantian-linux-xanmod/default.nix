{
  mode ? null,
  callPackage,
  lib,
  sources,
  ...
}:
let
  helpers = callPackage ./helpers.nix { inherit mode; };
  inherit (helpers) mkKernel;

  x86_64-march = [
    "v1"
    "v2"
    "v3"
    "v4"
  ];

  batch =
    {
      prefix,
      definitionDir,
      version,
      src,
      ...
    }:
    let
      prefix' = if prefix != "" then prefix + "-" else "";
    in
    lib.flatten (
      [
        (mkKernel {
          name = "${prefix'}generic";
          inherit version src sources;
          configFile = definitionDir + "/config.nix";
          patchDir = definitionDir + "/patches";
          lto = false;
        })
        (mkKernel {
          name = "${prefix'}generic-lto";
          inherit version src sources;
          configFile = definitionDir + "/config.nix";
          patchDir = definitionDir + "/patches";
          lto = true;
        })
      ]
      ++ (builtins.map (march: [
        (mkKernel {
          name = "${prefix'}x86_64-${march}";
          inherit version src sources;
          configFile = definitionDir + "/config.nix";
          patchDir = definitionDir + "/patches";
          lto = false;
          x86_64-march = march;
        })
        (mkKernel {
          name = "${prefix'}x86_64-${march}-lto";
          inherit version src sources;
          configFile = definitionDir + "/config.nix";
          patchDir = definitionDir + "/patches";
          lto = true;
          x86_64-march = march;
        })
      ]) x86_64-march)
    );

  batches =
    (batch {
      prefix = "";
      definitionDir = ./latest;
      inherit (sources.linux-xanmod) version src;
    })
    ++ (batch {
      prefix = "latest";
      definitionDir = ./latest;
      inherit (sources.linux-xanmod) version src;
    })
    ++ (batch {
      prefix = "lts";
      definitionDir = ./v6_6;
      inherit (sources.linux-xanmod-6_6) version src;
    })
    ++ (batch {
      prefix = "v6_6";
      definitionDir = ./v6_6;
      inherit (sources.linux-xanmod-6_6) version src;
    })
    ++ (batch {
      prefix = "v6_1";
      definitionDir = ./v6_1;
      inherit (sources.linux-xanmod-6_1) version src;
    })
    ++ (batch {
      prefix = "v6_0";
      definitionDir = ./v6_0;
      inherit (sources.linux-xanmod-6_0) version src;
    });

  batchesAttrs = builtins.listToAttrs batches;
in
if mode == "ci" then
  lib.filterAttrs (n: _v: lib.hasSuffix "configfile" n) batchesAttrs
else if mode == "nur" then
  lib.filterAttrs (n: _v: !lib.hasSuffix "configfile" n) batchesAttrs
else
  batchesAttrs
