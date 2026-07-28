{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  generatedConfig = pkgs.writeTextFile {
    name = "termux.properties";
    text = lib.generators.toKeyValue { } config.vacu.termuxProperties;
  };
  configDir = "${config.user.home}/.termux";
  propsSource = "${configDir}/termux.properties";
  propsBackup = "${propsSource}.bak";
in
{
  options.vacu.termuxProperties = mkOption {
    type = types.attrsOf types.str;
    default = { };
  };
  config.build.activation.vacuTermuxProperties =
    if config.vacu.termuxProperties == { } then
      ''
        if [ -e "${propsSource}" ] && [ -L "${propsSource}" ]; then
          $DRY_RUN_CMD rm $VERBOSE_ARG "${propsSource}"
          if [ -e "${propsBackup}" ]; then
            $DRY_RUN_CMD mv $VERBOSE_ARG "${propsBackup}" "${propsSource}"
            $DRY_RUN_CMD echo "${propsSource} has been restored from backup"
          else
            if $DRY_RUN_CMD rm $VERBOSE_ARG -d "${configDir}" 2>/dev/null
            then
              $DRY_RUN_CMD echo "removed empty ${configDir}"
            fi
          fi
        fi
      ''
    else
      ''
        $DRY_RUN_CMD mkdir $VERBOSE_ARG -p "${configDir}"
        if [ -e "${propsSource}" ] && ! [ -L "${propsSource}" ]; then
          $DRY_RUN_CMD mv $VERBOSE_ARG "${propsSource}" "${propsBackup}"
          $DRY_RUN_CMD echo "${propsSource} has been moved to ${propsBackup}"
        fi
        $DRY_RUN_CMD ln $VERBOSE_ARG -sf "${generatedConfig}" "${propsSource}"
      '';
}
