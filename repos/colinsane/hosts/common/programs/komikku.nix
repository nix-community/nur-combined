{ pkgs, ... }:
{
  sane.programs.komikku = {
    packageUnwrapped = pkgs.komikku.overrideAttrs (upstream: {
      preFixup = ''
        # 2024/07/25: Komikku uses XDG_SESSION_TYPE in the webkitgtk useragent, and errors if it's empty.
        #             XDG_SESSION_DESKTOP is used similarly in debug_info.py.
        #             TODO: patch/upstream Komikku
        gappsWrapperArgs+=(--set-default XDG_SESSION_TYPE "unknown" --set-default XDG_SESSION_DESKTOP "unknown")
      '' + (upstream.preFixup or "");
    });

    sandbox.net = "clearnet";
    sandbox.whitelistDri = true;  #< required
    sandbox.whitelistWayland = true;

    buildCost = 2;  # webkitgtk

    secrets.".local/share/komikku/keyrings/plaintext.keyring" = ../../../secrets/common/komikku_accounts.json.bin;
    # downloads end up here, and without the toplevel database komikku doesn't know they exist.
    persist.byStore.plaintext = [
      # also writes to ~/.cache/komikku
      ".local/share/komikku"
    ];
    persist.byStore.ephemeral = [
      ".cache/komikku"
    ];

    # XXX(2024-08-08): komikku can handle URLs from sources it understands (maybe), but not files (even if encoded as file:// URI)
    # mime.associations."application/vnd.comicbook+zip" = "info.febvre.Komikku.desktop";  # .cbz
  };
}
