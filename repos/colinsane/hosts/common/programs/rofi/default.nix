# rofi: app-launcher/file-browser/omni-menu
#
# select options:
# - `rofi -show`
#   - use as a launcher/file browser
# - `rofi -sidebar-mode`
#   - separate tabs for filebrowser, drun, etc.
# - `rofi -pid /run/user/$UID/rofi.pid -replace`
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
  rofi-unwrapped = pkgs.rofi-wayland-unwrapped.overrideAttrs (upstream: {
    # my patches made for tip don't cleanly apply to stable, so advance the entire src
    src = pkgs.fetchFromGitea {
      domain = "git.uninsane.org";
      owner = "colin";
      repo = "rofi";
      fetchSubmodules = true;
      # rev = "dev-sane";  #< fetchFromGitea doesn't support tags (?)
      rev = "3e7ed93b3a75b964d9c49f1322c9cc886f7d498e";
      hash = "sha256-wiQtdvnmju42jmi4UR8PYDL119Gt2DQ/3an4dmeMrjE=";
    };
    # patches = (upstream.patches or []) ++ [
    #   (pkgs.fetchpatch {
    #     url = "https://git.uninsane.org/colin/rofi/commit/d8bb0b9944ec1f3bf7479c9f127ec09d4198e87f.patch";
    #     name = "run-{shell-,}command: expand `{app_id}` inside the template string";
    #     hash = "sha256-XiZRvr+BARU7h3OPU0NUUEem3isnUVER69zucSqvNNk=";
    #   })
    # ];
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
    packageUnwrapped = pkgs.rofi-wayland.override {
      inherit rofi-unwrapped;
      plugins = [
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

    sandbox.method = "bwrap";
    sandbox.whitelistDbus = [ "user" ];  #< to launch apps via the portal
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".local/share/applications"  #< to locate .desktop files
      "Music"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "knowledge"
      "tmp"
    ];
    sandbox.extraPaths = [
      "/mnt/servo/media"
      "/mnt/servo/playground"
    ];

    fs.".config/rofi/config.rasi".symlink.target = ./config.rasi;
    # redirect its default drun cache location
    fs.".cache/rofi3.druncache".symlink.target = "rofi/rofi3.druncache";
    fs.".cache/rofi3.filebrowsercache".symlink.target = "rofi/rofi3.filebrowsercache";
    fs.".cache/rofi-drun-desktop.cache".symlink.target = "rofi/rofi-drun-desktop.cache";
    persist.byStore.cryptClearOnBoot = [
      # optional, for caching .desktop files rofi finds on disk (perf)
      ".cache/rofi"
    ];
  };

  sane.programs.rofi-run-command = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "rofi-run-command";
      srcRoot = ./.;
      pkgs = [ "sane-open-desktop" "xdg-utils" ];
    };
    sandbox.enable = false;  #< trivial script, and all our deps are sandboxed

    suggestedPrograms = [
      "sane-open-desktop"
      "xdg-utils"
    ];
  };

  sane.programs.rofi-snippets = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "rofi-snippets";
      srcRoot = ./.;
      pkgs = [
        "gnused"
        "rofi"
        "wtype"
      ];
      nativeBuildInputs = [
        pkgs.copyDesktopItems
      ];
      desktopItems = [
        (pkgs.makeDesktopItem {
          name = "rofi-snippets";
          exec = "rofi-snippets";
          desktopName = "rofi macro to insert common texts";
        })
      ];
    };
    # if i could remove the sed, then maybe possible to not sandbox.
    sandbox.method = "bwrap";
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".cache/rofi"
      ".config/rofi/config.rasi"
    ];

    suggestedPrograms = [ "rofi" ];

    fs.".config/rofi-snippets/public.txt".symlink.target = ./snippets.txt;
    secrets.".config/rofi-snippets/private.txt" = ../../../../secrets/common/snippets.txt.bin;
  };
}
