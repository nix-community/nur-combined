{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

let
  inherit (lib)
    mapAttrs'
    mkOption
    nameValuePair
    ;

  cfg = config.xdg;

  fileType =
    (import "${modulesPath}/lib/file-type.nix" {
      inherit (config.home) homeDirectory;
      inherit lib pkgs;
    }).fileType;
in
{
  meta.maintainers = with lib.maintainers; [ ilkecan ];

  options.xdg.binFile = mkOption {
    type = fileType "xdg.binFile" "`xdg.binHome`" cfg.binHome;
    default = { };
    description = ''
      Attribute set of files to link into the user's XDG bin home. Files are executable unless `executable` is set to `false`.
    '';
  };

  config.home.file = mapAttrs' (
    name: file:
    nameValuePair "${cfg.binHome}/${name}" (file // { executable = file.executable != false; })
  ) cfg.binFile;
}
