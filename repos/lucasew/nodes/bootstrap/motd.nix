{ self, config, pkgs, lib, ... }:
let
  figletedHostname = builtins.readFile (pkgs.runCommand "figlet" {} ''
  ${pkgs.figlet}/bin/figlet ${config.networking.hostName} > $out
'');
  mkDate = dateStr:
  let
    dateChars = lib.stringToCharacters dateStr;
    step = value: stepVal:
    if builtins.typeOf stepVal == "string" then
      (step (value + stepVal))
    else if builtins.typeOf stepVal == "int" then
      (step (value + (builtins.elemAt dateChars stepVal)))
    else value;
  in step "";
  mkInput = inputName:
  let
    input = self.inputs.${inputName};
    revDate = if (input.sourceInfo or null) != null then
      mkDate input.sourceInfo.lastModifiedDate 0 1 2 3 "/" 4 5 "/" 6 7 " " 8 9 ":" 10 11 ":" 12 13 null
      else "unknown";
    fullRev = "${inputName}@${input.shortRev} (${revDate})";
  in "${inputName}@${input.sourceInfo.lastModifiedDate or "unknown"}-${input.shortRev}";
in {
  users.motd = ''
${figletedHostname}
Configuration: nixcfg@${self.shortRev} (${mkDate self.sourceInfo.lastModifiedDate 0 1 2 3 "/" 4 5 "/" 6 7 " " 8 9 ":" 10 11 ":" 12 13 null})
Inputs: ${builtins.concatStringsSep " " (map (mkInput) (builtins.sort (a: b: a < b)(builtins.attrNames self.inputs)))}
  '';
}
