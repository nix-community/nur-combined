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
    echo $URL
    if [ -z "$URL" ]
    then
      ${zenity} --error --text="Nenhuma URL especificada"
      exit 1
    fi
    if [[ "$URL" =~ ^http(s)?:\/\/ ]]
    then
      true
    else
      URL="https://$URL"
    fi
    echo $URL
    ${chrome} --app="$URL"
  '';
  scriptDrv = pkgs.writeShellScript "webapp" script;
  scriptBin = pkgs.writeShellScriptBin "webapp" ''
    ${scriptDrv} "$@"
  '';
  desktop = pkgs.makeDesktopItem {
    name = "chrome-applauncher";
    desktopName = "Lançar site em janela borderless";
    type = "Application";
    icon = "applications-internet";
    exec = "${scriptBin}/bin/webapp";
  };
  joined = pkgs.symlinkJoin {
    name = "webapp";
    paths = [
      desktop
      scriptBin
    ];
  };
in joined // {
  wrap = {
    name
    ,desktopName ? name 
    ,url
    ,icon ? "applications-internet"
  }: pkgs.makeDesktopItem {
    name = name;
    desktopName = desktopName;
    type = "Application";
    icon = icon;
    exec = ''${scriptDrv} "${url}"'';
  };
}
