# Evaluation only: the example file is NOT decryptable and is never activated.
let
  flake = builtins.getFlake (toString ../.);
  evaluate = options: import (flake.inputs.nixpkgs.outPath + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    modules = [
      flake.nixosModules.kernel-publisher
      {
        system.stateVersion = "26.05";
        users.users.publisher = { isNormalUser = true; group = "users"; };
        services.urioNur.kernelPublisher = options;
      }
    ];
  };
  disabled = (evaluate { }).config;
  enabled = (evaluate {
    enable = true;
    user = "publisher";
    sopsFile = ../secrets/cachix.yaml.example;
  }).config;
  incomplete = (evaluate { enable = true; }).config;
  secret = enabled.sops.secrets.cachix_auth_token;
in
assert !(disabled.sops.secrets ? cachix_auth_token);
assert secret.owner == "publisher";
assert secret.group == "users";
assert secret.mode == "0400";
assert secret.key == "cachix_auth_token";
assert secret.format == "yaml";
assert secret.path == "/run/secrets/cachix_auth_token";
assert builtins.length (builtins.filter (a: !a.assertion && builtins.match ".*kernelPublisher.*" a.message != null) incomplete.assertions) == 2;
true
