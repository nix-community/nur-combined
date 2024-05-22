{ pkgs, ... }:

let
  inherit (builtins) readFile;

  handler = with pkgs; resholve.writeScriptBin "organize-downloads" {
    interpreter = "${bash}/bin/bash";
    inputs = [ coreutils efficient-compression-tool ];
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
