{ pkgs }:
let
getName = package: if pkgs.lib.hasAttr "executableName" package
                   then package.executableName
                   else pkgs.lib.lists.head (pkgs.lib.strings.splitString "-" package.name);
buildNameWrapper = a: ".local/share/applications/nix/${buildName a}.desktop";
buildValueWrapper = a: {text = buildDesktopFile a; };
buildName = {package, ...}: "${getName package}";
buildExecPath = {package, ...}: "${package}/bin/${getName package}";
buildIconPath = {package, ...}: "${package}/share/pixmaps/${getName package}.png";
buildDesktopFile = a@{package, ...}: 
  let
  name = if pkgs.lib.hasAttr "name" a then a.name else buildName a;
  exec = if pkgs.lib.hasAttr "exec" a then a.exec else buildExecPath a;
  icon = if pkgs.lib.hasAttr "icon" a then a.icon else buildIconPath a;
  type = if pkgs.lib.hasAttr "type" a then a.type else "Application";
  category = if pkgs.lib.hasAttr "category" a then a.category else "Misc";
  in
    ''
[Desktop Entry]
Encoding=UTF-8
Name=${name}
Exec=${exec}
Icon=${icon}
Type=${type}
Categories=${category};
    '';
in
a@{package, ...}: {
    name = (buildNameWrapper a);
    value = (buildValueWrapper a);
    }