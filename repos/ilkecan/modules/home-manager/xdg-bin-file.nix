{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

let
  cfg = config.xdg;

  fileType =
    (import "${modulesPath}/lib/file-type.nix" {
      inherit (config.home) homeDirectory;
      inherit lib pkgs;
    }).fileType;
in
{
  meta.maintainers = with lib.maintainers; [ ilkecan ];

  options.xdg.binFile = lib.mkOption {
    type = fileType "xdg.binFile" "`xdg.binHome`" cfg.binHome;
    default = { };
    description = ''
      Attribute set of files to link into the user's XDG bin home. Files are executable unless `executable` is set to `false`.
    '';
  };

  config.home.file = lib.mapAttrs' (
    name: file:
    lib.nameValuePair "${cfg.binHome}/${name}" (file // { executable = file.executable != false; })
  ) cfg.binFile;
}
