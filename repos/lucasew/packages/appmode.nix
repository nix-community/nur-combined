{pkgs ? import <nixpkgs> {}}:
let
  zenity = "${pkgs.gnome3.zenity}/bin/zenity";
  chrome = "${pkgs.google-chrome}/bin/google-chrome-stable";
  script = with pkgs; ''
    if [ -z "$@" ]
    then
      URL=$(${zenity} --entry --text="Link a ser aberto")
    else
      URL="$@"
    fi
    if [ -z "$URL" ]
    then
      ${zenity} --error --text="Nenhuma URL especificada"
      exit 1
    fi
    [[ "$URL" == '^http(s){0,1}:\/\/' ]] || URL="https://$URL"
    echo $URL
    ${chrome} --app="$URL"
  '';
  scriptDrv = pkgs.writeShellScript "webapp" script;
  desktop = pkgs.makeDesktopItem {
    name = "chrome-applauncher";
    desktopName = "Lançar site em janela borderless";
    type = "Application";
    icon = "applications-internet";
    exec = scriptDrv;
  };
in desktop
