{ lib, hostRegistry }:
let
  evaluate =
    device:
    (lib.evalModules {
      modules = [
        ../nixos/modules/device-options.nix
        { inherit device; }
      ];
    }).config.device;
  accepts = device: (builtins.tryEval (builtins.deepSeq (evaluate device) true)).success;
  linux = { };
  darwin = {
    system = "aarch64-darwin";
  };
  normalizedUsers =
    (evaluate (
      linux
      // {
        users = [
          "alice"
          {
            name = "bob";
            homeManager.enable = false;
          }
          {
            name = "carol";
            homeManager.module = "nixos/pwnbox";
          }
        ];
      }
    )).users;
in
# Force the actual option types, including those lazy host builders may not read.
assert lib.all (host: accepts host.device) hostRegistry.all;
assert lib.all (profile: accepts (linux // { inherit profile; })) [
  "core"
  "server"
  "desktop"
  "laptop"
  "vm"
  "vm/virtualbox"
];
assert lib.all (profile: !(accepts (linux // { inherit profile; }))) [
  7
  true
  null
  [ ]
  { }
];
assert accepts (linux // { stateVersion = "25.11"; });
assert !(accepts (linux // { stateVersion = 7; }));
assert accepts (darwin // { stateVersion = 7; });
assert !(accepts (darwin // { stateVersion = "25.11"; }));
assert (evaluate linux).stateVersion == "26.05";
assert (evaluate darwin).stateVersion == 6;
assert accepts { };
assert (evaluate { }).system == "x86_64-linux";
assert (evaluate { }).enable;
assert !(hostRegistry.byBackend.darwin ? charles);
assert (evaluate linux).profile == "server";
assert (evaluate linux).compositors == [ ];
assert
  builtins.head normalizedUsers == {
    name = "alice";
    groups = [ ];
    packages = [ ];
    sshKey = "";
    homeManager = {
      enable = true;
      module = "auto";
    };
  };
assert
  (builtins.elemAt normalizedUsers 1).homeManager == {
    enable = false;
    module = "auto";
  };
assert
  (builtins.elemAt normalizedUsers 2).homeManager == {
    enable = true;
    module = "nixos/pwnbox";
  };
true
