{ pkgs, config, lib, ... }: with lib; let
  cfg = config.services.mosh;
  mosh-server = pkgs.writeShellScriptBin "mosh-server" ''
    if [[ $1 != new ]]; then
      echo "unknown command $1" >&2
      exit 1
    fi
    shift

    ${pkgs.mosh}/bin/mosh-server new -p ${cfg.portRange} "$@"
  '';
in {
  options.services.mosh = {
    portRange = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "30000:40000";
    };
  };

  config = { };

  # TODO: actually implement this by putting ${mosh-server} in $PATH
}
