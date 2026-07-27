{
  config,
  inputs,
  lib,
  ...
}:

let
  generatePaths = prefix: pathsList: map (dir: "${prefix}/${dir}") pathsList;
  common_config_dirs = generatePaths ".config/" (
    lib.importJSON "${inputs.self}/home/users/bjorn/misc/persistence/common_config_dirs.json"
  );
  work_config_dirs = generatePaths ".config/" (
    lib.importJSON "${inputs.self}/home/users/bjorn/misc/persistence/work_config_dirs.json"
  );
  common_dirs = lib.importJSON "${inputs.self}/home/users/bjorn/misc/persistence/common_dirs.json";
in
{
  home.persistence."/mnt/persist" = {
    directories =
      common_config_dirs
      ++ common_dirs
      ++ (lib.optionals config.personaj.work.simplerisk.enable (work_config_dirs ++ [ ".aws" ]));
    files =
      let
        configFiles = generatePaths ".config" [
          "mimeapps.list"
          "QtProject.conf"
        ];
      in
      configFiles
      ++ [
        ".wallpaper.jpg"
        ".lock.jpg"
      ];
  };
}
