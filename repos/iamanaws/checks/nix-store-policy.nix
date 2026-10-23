{ lib }:
let
  gib = 1024 * 1024 * 1024;
  evaluate =
    device: overrides:
    (lib.evalModules {
      specialArgs.hostConfig = { inherit device; };
      modules = [
        {
          options.nix.settings = lib.mkOption {
            type = lib.types.attrsOf lib.types.int;
          };
        }
        ../lib/nix-store-policy.nix
        { nix.settings = overrides; }
      ];
    }).config.nix.settings;
  thresholds = min: max: {
    min-free = min * gib;
    max-free = max * gib;
  };
in
assert lib.all (profile: evaluate { inherit profile; } { } == thresholds 20 40) [
  "desktop"
  "laptop"
  "desktop/example"
  "laptop/example"
];
assert lib.all (profile: evaluate { inherit profile; } { } == thresholds 2 5) [
  "core"
  "server"
  "vm"
  "vm/virtualbox"
];
assert evaluate { } { } == thresholds 2 5;
# Hosts can override both thresholds or just one, without mkForce.
assert evaluate { profile = "desktop"; } (thresholds 3 6) == thresholds 3 6;
assert evaluate { profile = "laptop"; } { min-free = 10 * gib; } == thresholds 10 40;
true
