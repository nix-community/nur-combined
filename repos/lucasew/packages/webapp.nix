{ pkgs ? import <nixpkgs> { } }:
let
  zenity = "${pkgs.gnome3.zenity}/bin/zenity";
  browser = "${pkgs.chromium}/bin/chromium";
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
    if [[ "$URL" =~ ^~ ]]
    then
      URL=$(echo $URL | sed -E s:^~\/?::)
      URL="file://$HOME/$URL"
    fi
    if [[ "$URL" =~ ^\/ ]]
    then
      URL="file://$URL"
    fi
    if [[ "$URL" =~ ^(file|http(s))?:\/\/ ]]
    then
      true
    else
      URL="https://$URL"
    fi
    echo $URL
    ${browser} --app="$URL"
  '';
  scriptDrv = pkgs.writeShellScript "webapp" script;
  scriptBin = pkgs.writeShellScriptBin "webapp" ''
    ${scriptDrv} "$@"
  '';
  desktop = pkgs.makeDesktopItem {
    name = "chrome-applauncher";
    desktopName = "Borderless Web Launcher";
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
in
joined // {
  wrap =
    { name
    , desktopName ? name
    , url
    , icon ? "applications-internet"
    }: pkgs.makeDesktopItem {
      name = name;
      desktopName = desktopName;
      type = "Application";
      icon = icon;
      exec = ''${scriptDrv} "${url}"'';
    };
}
