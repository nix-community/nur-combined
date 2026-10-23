{
  pkgs,
  inputs,
  hostRegistry,
}:
let
  inherit (pkgs) lib;
in
{
  profiles =
    assert import ./profiles.nix { inherit lib; };
    pkgs.runCommand "profile-module-checks" { } ''
      touch "$out"
    '';
  nix-store-policy =
    assert import ./nix-store-policy.nix { inherit lib; };
    pkgs.runCommand "nix-store-policy-checks" { } ''
      touch "$out"
    '';
  device-schema =
    assert import ./device-schema.nix { inherit lib hostRegistry; };
    pkgs.runCommand "device-schema-checks" { } ''
      touch "$out"
    '';
  host-builders =
    assert import ./host-builders.nix { inherit lib; };
    pkgs.runCommand "host-builder-checks" { } ''
      touch "$out"
    '';
  home-manager =
    assert import ./home-manager.nix { inherit inputs hostRegistry lib; };
    pkgs.runCommand "home-manager-output-checks" { } ''
      touch "$out"
    '';
}
// import ./integration.nix { inherit pkgs inputs hostRegistry; }
// lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  user-secrets =
    let
      config = inputs.self.nixosConfigurations.daedalus.config;
    in
    assert config.sops.secrets.passwd.neededForUsers;
    assert config.users.users.iamanaws.hashedPasswordFile == config.sops.secrets.passwd.path;
    assert lib.elem "setupSecretsForUsers" config.system.activationScripts.users.deps;
    pkgs.runCommand "user-secret-order-checks" { } ''
      touch "$out"
    '';
  dunst-scripts =
    pkgs.runCommand "dunst-script-checks"
      {
        nativeBuildInputs = with pkgs; [
          bash
          coreutils
          procps
          shellcheck
        ];
      }
      ''
        shellcheck -s bash ${../home/users/iamanaws/config/dunst/scripts}/*.sh
        bash ${./dunst.sh} ${../home/users/iamanaws/config/dunst/scripts}
        touch "$out"
      '';
}
