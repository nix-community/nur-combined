{ lib, pkgs, ... }:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
  inherit (pkgs) bash coreutils efficient-compression-tool findutils resholve;

  handler = resholve.writeScriptBin "organize-downloads" {
    interpreter = getExe bash;
    inputs = [ coreutils efficient-compression-tool findutils ];
  } (readFile ./resources/organize-downloads);
in
{
  config = {
    systemd.user.paths.organize-downloads = {
      Unit.Description = "Watch downloads";
      Path.PathExistsGlob = "%h/Downloads/Screen{s,\\ S}hot\\ *.png";
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.organize-downloads = {
      Unit.Description = "Organize downloads";
      Service.ExecStart = "${handler}/bin/organize-downloads";
      Service.Nice = 10;
    };
  };
}
