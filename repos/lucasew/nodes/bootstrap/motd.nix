{ self, config, pkgs, lib, ... }:
let
  in {
  environment.dotd."/etc/motd-bash".enable = true;

  programs.bash.promptInit = ''
    if [ ! "$TERM" == "dumb" ]; then
      cat /etc/motd-bash
    fi
  '';

  environment.etc."motd-bash.d/01-hostname-figlet".source = pkgs.runCommand "figlet" {} ''
    printf "%s" "[?7l[1m
  [34m  \\  \\ //
  [34m ==\\__\\/ //
  [34m   //   \\//
  [34m==//     //==
  [34m //\\___//
  [34m// /\\  \\==
  [34m  // \\  \\

[m[8A[1m" > $out
    ${pkgs.figlet}/bin/figlet ${config.networking.hostName} | sed 's;\([^$]*\);[17C\1[m;' >> $out
    echo -e "\n[0m[?7h" >> $out

  '';

  environment.etc."motd-bash.d/09-space".text = "\n";

  systemd.services."motd-uptime" = {
    enable = true;
    restartIfChanged = true;
    wantedBy = [ "multi-user.target" ];
    script = ''
    uptime > /run/uptime
    while true; do
      echo > /etc/motd-bash.d/00-uptime-trigger
      sleep 0.01
      uptime > /run/uptime
    done
    '';
  };
  systemd.tmpfiles.rules = [
    "p+ /etc/motd-bash.d/00-uptime-trigger 0644 root root"
  ];

  environment.etc."motd-bash.d/10-uptime".source = "/run/uptime";

  environment.etc."motd-bash.d/11-space".text = "\n";

  environment.etc."motd-bash.d/21-system-commit".text = let
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
  in ''

[34;1mConfiguration:[m nixcfg@${self.shortRev} (${mkDate self.sourceInfo.lastModifiedDate 0 1 2 3 "/" 4 5 "/" 6 7 " " 8 9 ":" 10 11 ":" 12 13 null})
[34;1mInputs:[m ${builtins.concatStringsSep " " (map (mkInput) (builtins.sort (a: b: a < b)(builtins.attrNames self.inputs)))}
  '';


  environment.etc."motd-bash.d/98-space".text = "\n";
  environment.etc."motd-bash.d/99-cockpit" = lib.mkIf config.services.cockpit.enable {
    source = "/run/cockpit/active.motd";
  };
}
