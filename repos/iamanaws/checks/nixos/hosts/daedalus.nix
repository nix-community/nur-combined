{ inputs, lib, ... }:
let
  config = inputs.self.nixosConfigurations.daedalus.config;
in
assert config.sops.secrets.passwd.neededForUsers;
assert config.users.users.iamanaws.hashedPasswordFile == config.sops.secrets.passwd.path;
assert lib.elem "setupSecretsForUsers" config.system.activationScripts.users.deps;
true
