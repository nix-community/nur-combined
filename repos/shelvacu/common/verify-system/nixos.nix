{
  lib,
  config,
  pkgs,
  vacuModuleType,
  ...
}:
let
  inherit (lib) mkOption types;
in
lib.optionalAttrs (vacuModuleType == "nixos") {
  options.vacu.verifySystem.expectedMac = mkOption {
    # lowercase only
    type = types.nullOr (types.strMatching "[a-f0-9]{2}(:[a-f0-9]{2}){5}");
    default = null;
  };
  config = lib.mkIf config.vacu.verifySystem.enable {
    # system.activationScripts."00-verify-system" = {
    #   text = "if ! source ${config.vacu.verifySystem.verifyAllScript}; then exit $?; fi";
    #   supportsDryActivation = true;
    # };

    system.extraSystemBuilderCmds = ''
      mv "$out"/bin/switch-to-configuration "$out"/bin/.switch-to-configuration-unverified
      echo '#!${pkgs.bash}/bin/bash
      (
        PATH="${pkgs.coreutils}/bin"
        if ! source ${config.vacu.verifySystem.verifyAllScript}; then
          exit $?
        fi
      )
      ' > "$out"/bin/switch-to-configuration
      echo "exec $out/bin/.switch-to-configuration-unverified" '"$@"' >> "$out"/bin/switch-to-configuration

      chmod a+x "$out"/bin/switch-to-configuration
    '';

    vacu.verifySystem.verifiers = {
      hostname = {
        enable = lib.mkDefault config.vacu.verifySystem.expectedMac == null;
        script = ''
          expected=${lib.escapeShellArg config.networking.hostName}
          actual="$(</proc/sys/kernel/hostname)"
          if [[ "$expected" != "$actual" ]]; then
            echo "ERR: unexpected hostname; Trying to deploy to $expected but this is $actual" >&2
            return 1
          fi
        '';
      };
      expectedMac = {
        enable = config.vacu.verifySystem.expectedMac != null;
        script = ''
          declare expected=${lib.escapeShellArg (lib.toUpper config.vacu.verifySystem.expectedMac)}
          declare -a actualMacs
          mapfile -d"" -t actualMacs < <(${pkgs.iproute2}/bin/ip -j link | ${pkgs.jq}/bin/jq 'map([.permaddr, .address] | map(strings | ascii_upcase)) | flatten[]' --raw-output0)
          for ifMac in "''${actualMacs[@]}"; do
              if [[ "$ifMac" == "$expected" ]]; then
              # all is well
              return 0
             fi
          done
          echo "ERR: Interface MAC address $expected not present, this may not be the system you intend to deploy to." >&2
          echo "     Found MAC addresses: ''${actualMacs[*]}" >&2
          return 1
        '';
      };
    };
  };
}
