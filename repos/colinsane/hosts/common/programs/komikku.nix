{ pkgs, ... }:
{
  sane.programs.komikku = {
    packageUnwrapped = pkgs.komikku.overrideAttrs (upstream: {
      preFixup = ''
        # 2024/02/21: render bug which affects only moby:
        #             large images render blank in several gtk applications.
        #             may resolve itself as gtk or mesa are updated.
        gappsWrapperArgs+=(--set GSK_RENDERER cairo)
      '' + (upstream.preFixup or "");
    });

    sandbox.method = "bwrap";  # TODO:sandbox untested
    sandbox.net = "clearnet";
    sandbox.whitelistDbus = [ "user" ];  # needs to connect to dconf via dbus
    sandbox.whitelistDri = true;  #< required
    sandbox.whitelistWayland = true;

    buildCost = 1;

    secrets.".local/share/komikku/keyrings/plaintext.keyring" = ../../../secrets/common/komikku_accounts.json.bin;
    # downloads end up here, and without the toplevel database komikku doesn't know they exist.
    persist.byStore.plaintext = [
      # also writes to ~/.cache/komikku
      ".local/share/komikku"
    ];
  };
}
