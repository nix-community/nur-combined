{
  mode ? null,
  callPackage,
  lib,
  sources,
  ...
}:
let
  mkXanmodKernel = callPackage ./mkXanmodKernel.nix { inherit mode sources; };

  x86_64-march = [
    "v1"
    "v2"
    "v3"
    "v4"
  ];

  batch =
    {
      prefix,
      version,
      src,
      ...
    }:
    let
      prefix' = if prefix != "" then prefix + "-" else "";
    in
    [
      (mkXanmodKernel {
        pname = "${prefix'}generic";
        inherit version src;
        lto = false;
      })
      (mkXanmodKernel {
        pname = "${prefix'}generic-lto";
        inherit version src;
        lto = true;
      })
    ]
    ++ lib.optionals (lib.versionOlder version "6.12") (
      builtins.map (march: [
        (mkXanmodKernel {
          pname = "${prefix'}x86_64-${march}";
          inherit version src;
          lto = false;
          x86_64-march = march;
        })
        (mkXanmodKernel {
          pname = "${prefix'}x86_64-${march}-lto";
          inherit version src;
          lto = true;
          x86_64-march = march;
        })
      ]) x86_64-march
    );

  batches = [
    (batch {
      prefix = "";
      inherit (sources.linux-xanmod) version src;
    })
    (batch {
      prefix = "latest";
      inherit (sources.linux-xanmod) version src;
    })
    (batch {
      prefix = "lts";
      inherit (sources.linux-xanmod-6_12) version src;
    })
    (batch {
      prefix = "v6_12";
      inherit (sources.linux-xanmod-6_12) version src;
    })
    (batch {
      prefix = "v6_6";
      inherit (sources.linux-xanmod-6_6) version src;
    })
    (batch {
      prefix = "v6_1";
      inherit (sources.linux-xanmod-6_1) version src;
    })
    (batch {
      prefix = "v6_0";
      inherit (sources.linux-xanmod-6_0) version src;
    })
  ];

  batchesAttrs = builtins.listToAttrs (lib.flatten batches);
in
if mode == "ci" then
  lib.filterAttrs (n: _v: lib.hasSuffix "configfile" n) batchesAttrs
else if mode == "nur" then
  lib.filterAttrs (n: _v: !lib.hasSuffix "configfile" n) batchesAttrs
else
  batchesAttrs
