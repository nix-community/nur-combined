{ config, pkgs, ... }:
let

  homeManagerHas = package:
    builtins.any (user:
      if (builtins.hasAttr package user.programs) then
        user.programs."${package}".enable
      else
        false) (builtins.attrValues config.home-manager.users);

  # Logic becomes that a user has installed an application with X
  # name via homebrew nix module - this notably is possible to include masApps
  # see also: https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.masApps
  homeBrewHas = package:
    (builtins.elem package (builtins.map (x: x.name) config.homebrew.casks)
      || builtins.elem package (builtins.map (x: x.name) config.homebrew.brews)
      || builtins.elem package (builtins.attrNames config.homebrew.masApps));

  anyUserHas = package: (homeBrewHas package || homeManagerHas package);

  alacrittyEntry =
    [{ path = "${pkgs.alacritty.outPath}/Applications/Alacritty.app"; }];
  firefoxEntry =
    [{ path = "${pkgs.firefox-bin.outPath}/Applications/Firefox.app"; }];
  braveEntry = [{ path = "/Applications/Brave Browser.app"; }];
  chromiumEntry = [{ path = "/Applications/Chromium.app"; }];
  vscodiumEntry =
    [{ path = "${pkgs.vscodium.outPath}/Applications/VSCodium.app"; }];
  keepassEntry = [{ path = "/Applications/KeePassXC.app"; }];
  outlookEntry = [{ path = "/Applications/Microsoft Outlook.app"; }];
  slackEntry = [{ path = "/Applications/Slack.app"; }];

  entries = [ ] ++ (if anyUserHas "alacritty" then alacrittyEntry else [ ])
    ++ (if anyUserHas "firefox" then firefoxEntry else [ ])
    ++ (if anyUserHas "brave-browser" then braveEntry else [ ])
    ++ (if anyUserHas "eloston-chromium" || anyUserHas "chromium" then
      chromiumEntry
    else
      [ ])
    # Gross hack - TODO: fix later
    ++ (if anyUserHas "vscode" then vscodiumEntry else [ ])
    ++ (if anyUserHas "keepassxc" then keepassEntry else [ ])
    ++ (if anyUserHas "Microsoft Outlook" then outlookEntry else [ ])
    ++ (if anyUserHas "slack" then slackEntry else [ ]);

in {
  imports = [ ../../options/dockutil ];

  dockutil = {
    enable = true;
    inherit entries;
  };
}
