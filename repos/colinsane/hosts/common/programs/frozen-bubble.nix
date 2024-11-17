# source code: <https://github.com/kthakore/frozen-bubble>
{ pkgs, ... }:
{
  sane.programs.frozen-bubble = {
    packageUnwrapped = pkgs.frozen-bubble.overrideAttrs (upstream: {
      # patch so it stores its dot-files not in root ~.
      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace lib/Games/FrozenBubble/Stuff.pm \
          --replace-fail '$FBHOME   = "$ENV{HOME}/.frozen-bubble"' '$FBHOME   = "$ENV{HOME}/.local/share/frozen-bubble"'
      '';
    });
    buildCost = 1;

    sandbox.net = "clearnet";  # net play
    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;

    persist.byStore.plaintext = [
      ".local/share/frozen-bubble"  # preferences, high scores
    ];
  };
}
