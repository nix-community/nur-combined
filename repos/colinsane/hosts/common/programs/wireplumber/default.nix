{ config, lib, pkgs, ... }:
let
  rewriteRequires = src:
    lib.replaceStrings
      [ ''require("./'' ]
      [ ''require("/home/colin/.local/share/wireplumber/scripts/'' ]
      src
    ;
in
{
  sane.programs.wireplumber = {
    packageUnwrapped = pkgs.wireplumber.override {
      # use the same pipewire as configured to run against.
      pipewire = config.sane.programs.pipewire.packageUnwrapped;
    };

    sandbox.whitelistDbus.user = true;  #< required for camera sharing, especially through xdg-desktop-portal, e.g. `snapshot` application  (TODO: reduce)
    sandbox.whitelistDbus.system = true;  #< required to handshake with bluetooth audio devices. also grants access to rtkit (optional integration; not much lost if omitted)
    sandbox.whitelistAudio = true;
    sandbox.whitelistAvDev = true;
    # sandbox.keepPids = true;  #< needed if i want rtkit to grant this higher scheduling priority
    # sandbox.net = "all";  #< needed if you want to plug audio devices at runtime (udev; AF_NETLINK)

    sandbox.extraHomePaths = [
      ".config/wireplumber"
    ];

    suggestedPrograms = [ "alsa-ucm-conf" ];

    persist.byStore.plaintext = [
      # persist per-device volume levels, device <-> client links, etc.
      # files:
      # - default-nodes:
      #   - ranked preferences for which device to make the default audio sink/source.
      # - stream-properties:
      #   - per-application volume & mute states
      # - default-routes:
      #   - soundcard volume & mute states
      # - default-profile:
      #   - default soundcard?
      ".local/state/wireplumber"
    ];

    fs.".local/share/wireplumber/scripts/autolink-mic-effects.lua".symlink.text = rewriteRequires (builtins.readFile ./scripts/autolink-mic-effects.lua);
    fs.".local/share/wireplumber/scripts/dump-common.lua".symlink.text = rewriteRequires (builtins.readFile ./scripts/dump-common.lua);
    # N.B.: these are debugging conveniences -- not required for operation
    fs.".local/share/wireplumber/scripts/dump-links.lua".symlink.text = rewriteRequires (builtins.readFile ./scripts/dump-links.lua);
    fs.".local/share/wireplumber/scripts/dump-nodes.lua".symlink.text = rewriteRequires (builtins.readFile ./scripts/dump-nodes.lua);
    fs.".local/share/wireplumber/scripts/dump-ports.lua".symlink.text = rewriteRequires (builtins.readFile ./scripts/dump-ports.lua);
    fs.".local/share/wireplumber/scripts/dump-sources.lua".symlink.text = rewriteRequires (builtins.readFile ./scripts/dump-sources.lua);
    fs.".local/share/wireplumber/scripts/monitor-events.lua".symlink.text = rewriteRequires (builtins.readFile ./scripts/monitor-events.lua);

    fs.".config/wireplumber/wireplumber.conf.d/10-sane-config.conf".symlink.target = ./wireplumber.conf.d/10-sane-config.conf;
    fs.".config/wireplumber/wireplumber.conf.d/20-mic-effects.conf".symlink.target = ./wireplumber.conf.d/20-mic-effects.conf;

    services.wireplumber = {
      description = "wireplumber: pipewire Multimedia Service Session Manager";
      depends = [ "pipewire" ];
      partOf = [ "sound" ];
      command = "wireplumber";
    };
  };
}
