{ self, config, pkgs, lib, ... }:

let

  inherit (lib) concatStringsSep attrValues mapAttrs;
  inherit (pkgs.custom.colors.colors) base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F;


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
      <meta name="viewport" content="width=device-width,initial-scale=1" />
      <title>${config.networking.hostName}</title>
      <style>

:root {
  --base00: #${base00};
  --base01: #${base01};
  --base02: #${base02};
  --base03: #${base03};
  --base04: #${base04};
  --base05: #${base05};
  --base06: #${base06};
  --base07: #${base07};
  --base08: #${base08};
  --base09: #${base09};
  --base0A: #${base0A};
  --base0B: #${base0B};
  --base0C: #${base0C};
  --base0D: #${base0D};
  --base0E: #${base0D};
  --base0F: #${base0E};
  background-color: var(--base00);
  color: var(--base05);
}

a {
  color: var(--base0C);
}

a:visited {
  color: var(--base0D);
}

a:active {
  color: var(--base0C);
}

span .hidden-part {
    transition: 0.5s;
}
span:hover .hidden-part {
  display: inherit;
  background-color: var(--base01);
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
        <svg width="50px" height="50px" viewBox="0 0 100 100">
          <g transform="scale(1)">
            <g transform="matrix(.19936 0 0 .19936 80.161 27.828)">
              <path d="m-53.275 105.84-122.2-211.68 56.157-0.5268 32.624 56.869 32.856-56.565 27.902 0.011 14.291 24.69-46.81 80.49 33.229 57.826zm-142.26 92.748 244.42 0.012-27.622 48.897-65.562-0.1813 32.559 56.737-13.961 24.158-28.528 0.031-46.301-80.784-66.693-0.1359zm-9.3752-169.2-122.22 211.67-28.535-48.37 32.938-56.688-65.415-0.1717-13.942-24.169 14.237-24.721 93.111 0.2937 33.464-57.69z" fill="#${base0C}"/>
              <path d="m-97.659 193.01 122.22-211.67 28.535 48.37-32.938 56.688 65.415 0.1716 13.941 24.169-14.237 24.721-93.111-0.2937-33.464 57.69zm-9.5985-169.65-244.42-0.012 27.622-48.897 65.562 0.1813-32.559-56.737 13.961-24.158 28.528-0.031 46.301 80.784 66.693 0.1359zm-141.76 93.224 122.2 211.68-56.157 0.5268-32.624-56.869-32.856 56.565-27.902-0.011-14.291-24.69 46.81-80.49-33.229-57.826z" fill="#${base0D}" style="isolation:auto;mix-blend-mode:normal"/>
            </g>
          </g>
        </svg>
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
    sha256 = "sha256-5inMf6x/pZ3E2UVz5+Z/N8Ic/2uV2jhrVeD111uK/Jg=";
  };

  services.nginx.virtualHosts."${config.networking.hostName}" = {
    locations."/".root = "/etc/rootdomain";
  };
  services.nginx.virtualHosts."${config.networking.hostName}.${config.networking.domain}" = {
    locations."/".root = "/etc/rootdomain";
  };
  services.nginx.virtualHosts."index.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/".root = "/etc/rootdomain";
  };
}
