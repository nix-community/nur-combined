# rofi: app-launcher/file-browser/omni-menu
#
# select options:
# - `rofi -show`
#   - use as a launcher/file browser
# - `rofi -sidebar-mode`
#   - separate tabs for filebrowser, drun, etc.
# - `rofi -pid $XDG_RUNTIME_DIR/rofi.pid -replace`
#   - single-instance mode
#   - pid is probably optional, just need `-replace`.
#
# ROFI POWERSCRIPTS/EXTENSIONS/PLUGINS:
# collections:
# - <https://github.com/adi1090x/rofi>
# - <https://github.com/giomatfois62/rofi-desktop>
#   - turns rofi into a hierarchical menu, like sxmo
#
# - <https://github.com/adi1090x/rofi>
# - <https://github.com/marvinkreis/rofi-file-browser-extended>
# - <https://github.com/Mange/rofi-emoji>
# - <https://github.com/fdw/rofimoji>
# - <https://github.com/jluttine/rofi-power-menu>
# - <https://github.com/ceuk/rofi-screenshot>
# - <https://gitlab.com/DamienCassou/rofi-pulse-select>
{ pkgs, ... }:
let
  rofi-unwrapped = pkgs.rofi-unwrapped.overrideAttrs (upstream: {
    patches = (upstream.patches or []) ++ [
      (pkgs.fetchpatch {
        # so that i can open applications via the xdg-desktop-portal instead of by having rofi launch them directly.
        # N.B.: since 1.7.6, rofi is able to dbus-activate applications as well
        url = "https://git.uninsane.org/colin/rofi/commit/81e9d6ca1f7c5367752a81e39d30908a3e8e65cf.patch";
        name = "run-{shell-,}command: expand `{app_id}` inside the template string";
        hash = "sha256-g7802EDxt/iOLTslhzKaYpy0bDUeHCo7yacRJnF/1/o=";
      })
      (pkgs.fetchpatch {
        # workaround for <https://github.com/davatorium/rofi/issues/1954>
        # which was only ever fixed for the *recursive* file browser.
        # maintainer doesn't want to `stat` in non-recursive file browser yet; defer patching until filebrowser is made to be async
        url = "https://git.uninsane.org/colin/rofi/commit/ede969e9ce4b549ad0b28cfb36f9e5a156114d70.patch";
        name = "filebrowser: include entries of d_type DT_UNKNOWN";
        hash = "sha256-gz3N4uo7IWzzqaPHHVhby/e9NbtzcFJRQwgdNYxO/Yw=";
      })
      (pkgs.fetchpatch {
        # out for PR upstream: <https://github.com/davatorium/rofi/pull/2201>
        url = "https://git.uninsane.org/colin/rofi/commit/375e54332b9e269e3367c9724f8828534ffeb414.patch";
        name = "filebrowser: sort based on natural ordering";
        hash = "sha256-BzVAMBz4XSYLFN6Gz7HW+2ACrszvjCDK7RBt4rXxnOk=";
      })
    ];

    nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
      pkgs.copyDesktopItems
    ];
    desktopItems = (upstream.desktopItems or []) ++ [
      (pkgs.makeDesktopItem {
        name = "rofi-filebrowser";
        # alternatively: `rofi -modes filebrowser -show`, however this would require theme tweaking to look good
        exec = "rofi -combi-modes filebrowser -show";
        desktopName = "Files (rofi)";
      })
      (pkgs.makeDesktopItem {
        name = "rofi-applications";
        exec = "rofi -combi-modes drun -show";
        desktopName = "Applications (rofi)";
        mimeTypes = [ "application/x-desktop" ];
        noDisplay = true;
      })
      (pkgs.makeDesktopItem {
        name = "rofi-cancel";
        exec = "true";
        desktopName = "Cancel";
        mimeTypes = [ "application/x-desktop" ];
      })
    ];
  });
  # rofi-emoji = pkgs.rofi-emoji.override {
  #   # plugins must be compiled against the same rofi they're loaded by
  #   inherit rofi-unwrapped;
  # };
  # rofi-file-browser = pkgs.rofi-file-browser.override {
  #   # plugins must be compiled against the same rofi they're loaded by
  #   rofi = rofi-unwrapped;
  # };
in
{
  sane.programs.rofi = {
    # 2024/02/26: wayland is only supported by the fork: <https://github.com/lbonn/rofi>.
    # it's actively maintained though, and more of an overlay than a true fork.
    packageUnwrapped = pkgs.rofi.override {
      inherit rofi-unwrapped;
      plugins = with pkgs; [
        # rofi-calc  # not compatible with my rofi <https://github.com/svenstaro/rofi-calc>
        # rofi-[extended-]-file-browser: <https://github.com/marvinkreis/rofi-file-browser-extended>
        # because the builtin rofi filebrowser only partially lists ~/Videos/servo/Shows, seemingly at random.
        # but rofi-file-browser doesn't compile against my patched rofi (oops)
        # rofi-file-browser

        # rofi-emoji: "insert" mode doesn't work; use a wrapper like `splatmoji` instead.
        # rofi-emoji
      ];
    };

    suggestedPrograms = [
      "rofi-run-command"
    ];

    sandbox.whitelistDbus.user = true;  #< TODO: should only need DynamicLauncher / OpenURI  (nested xdg-dbus-proxy issue?)
    # sandbox.whitelistPortal = [
    #   "DynamicLauncher"
    #   "OpenURI"
    # ];
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".local/share/applications"  #< to locate .desktop files
      "Books/Audiobooks"
      "Books/Books"
      "Books/Visual"
      "Books/local"
      "Books/servo"
      "Music"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/gPodder"
      "Videos/local"
      "Videos/servo"
      "knowledge"
      "tmp"
    ];
    sandbox.extraPaths = [
      "/mnt/servo/media"
      "/mnt/servo/playground"
    ];
    sandbox.keepPidsAndProc = true; # for sane-open to toggle keyboard

    fs.".config/rofi/config.rasi".symlink.target = ./config.rasi;
    fs."Apps".symlink.target = ".local/share/applications/rofi-applications.desktop";  #< provide a means to transition from the filebrowser to the app launcher
    fs."Cancel".symlink.target = ".local/share/applications/rofi-cancel.desktop";  #< provide an escape from the file browser
    fs."WiFi".symlink.target = ".local/share/applications/networkmanager_dmenu.desktop";
    persist.byStore.ephemeral = [
      # this gets us a few things:
      # - file browser remembers its last directory
      # - caching of .desktop files (perf)
      ".cache/rofi"
    ];
  };

  sane.programs.rofi-run-command = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "rofi-run-command";
      srcRoot = ./.;
      pkgs = [ "sane-open" ];
    };
    # sandboxing options cribbed from sane-open
    sandbox.autodetectCliPaths = "existing";  # for when opening a file
    sandbox.whitelistPortal = [
      "DynamicLauncher"
      "OpenURI"
    ];
    sandbox.keepPidsAndProc = true;
    sandbox.extraHomePaths = [ ".local/share/applications" ];
    sandbox.extraRuntimePaths = [ "sway" ];

    suggestedPrograms = [
      "sane-open"
      "xdg-utils"
    ];
  };

  sane.programs.rofi-snippets = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "rofi-snippets";
      srcRoot = ./.;
      pkgs = {
        inherit (pkgs) gnused wtype;
        rofi = pkgs.rofi.override {
          inherit rofi-unwrapped;
        };
      };
      nativeBuildInputs = [
        pkgs.copyDesktopItems
      ];
      desktopItems = [
        (pkgs.makeDesktopItem {
          name = "rofi-snippets";
          exec = "rofi-snippets";
          # rofi macro to insert common texts
          desktopName = "Snippets";
        })
      ];
    };
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".cache/rofi"
      ".config/rofi/config.rasi"
    ];

    suggestedPrograms = [ "gnused" "rofi" "wtype" ];

    fs.".config/rofi-snippets/public.txt".symlink.target = ./snippets.txt;
    secrets.".config/rofi-snippets/private.txt" = ../../../../secrets/common/snippets.txt.bin;
  };
}
