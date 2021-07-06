{ config, lib, ... }: with lib; let
  cfg = config.services.pipewire;
in {
  options.services.pipewire = {
    links = mkOption {
      type = with types; attrsOf (coercedTo str singleton (listOf str));
      default = { };
    };
  };

  config = mkIf config.services.pipewire.enable {
    systemd.user.services.pipewire-links = mkIf (config.services.pipewire.links != { }) rec {
      after = [ "pipewire.service" "pipewire.socket" ];
      requisite = singleton "pipewire.service";
      wantedBy = singleton "pipewire.service";
      script = mkMerge (
        singleton "sleep 2" # TODO: hack!
        ++ concatLists (mapAttrsToList (input: outputs: map (output:
          ''${cfg.package}/bin/pw-link -P ${input} ${output} || echo failed to link "${input} => ${output}" >&2''
        ) outputs) cfg.links)
      );
    };
  };
}
