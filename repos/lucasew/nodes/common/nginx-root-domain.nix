{ self, config, pkgs, lib, ... }:

with pkgs.custom.colors.colors;
let
  inherit (lib) concatStringsSep attrValues mapAttrs;

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
  in ''<span><b>${inputName}</b> <span class="hidden-part">${input.sourceInfo.lastModifiedDate or "unknown"}-${input.shortRev}</span></span>'';

  template = ''
<!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <title>${config.networking.hostName}</title>
      <style>

span .hidden-part {
    transition: 0.5s;
}
span:hover .hidden-part {
  display: inherit;
}

span:not(:hover) .hidden-part {
  display: none;
}

.small-cards-container {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  flex-direction: row;
}

.small-cards-container > * {
  margin: 0.2rem;
  display: inline-block;
  white-space: nowrap;
  text-align: center;
}

section#hello {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
}

section#hello > * {
  margin: 0;
  padding-left: 1rem;
  display: inline-block;
}

a {
  font-weight: bold;
}

      </style>
    </head>

    <body>
      <section id="hello">
        <img style="height: 4rem; width: auto;" src="/nix-logo.png">
        <h1 style="font-size: 4rem;">${config.networking.hostName}</h1>
      </section>
      <section id="nginx">
        <h2>Nginx hosts</h2>
        <div class="small-cards-container">
        ${concatStringsSep "\n" (attrValues (mapAttrs
          (k: v: ''
            <a class="btn btn-light" target="_blank" href="http://${k}">${k}</a>
          '') (config.services.nginx.virtualHosts)
        ))}
        </div>
      </section>

      <section id="versions">
        <h2>Inputs</h2><br>
            <div class="small-cards-container">
              <span><b>nixcfg</b> <span class="hidden-part">${self.shortRev}  (${mkDate self.sourceInfo.lastModifiedDate 0 1 2 3 "/" 4 5 "/" 6 7 " " 8 9 ":" 10 11 ":" 12 13 null})</span></span>

              ${builtins.concatStringsSep " " (map (mkInput) (builtins.sort (a: b: a < b)(builtins.attrNames self.inputs)))}
            </div>
      </section>

    </body>

  </html>
  '';
in
{
  environment.etc."rootdomain/index.html".source = pkgs.writeText "template.html" template;
  environment.etc."rootdomain/favicon.ico".source = pkgs.fetchurl {
    url = "https://nixos.org/favicon.ico";
    sha256 = "sha256-59/+37K66dD+ySkvZ5JS/+CyeC2fDD7UAr1uiShxwYM=";
  };
  environment.etc."rootdomain/nix-logo.png".source = "${pkgs.nixos-icons}/share/icons/hicolor/1024x1024/apps/nix-snowflake.png";

  services.nginx.virtualHosts."${config.networking.hostName}.${config.networking.domain}" = {
    locations."/".root = "/etc/rootdomain";
  };
}
