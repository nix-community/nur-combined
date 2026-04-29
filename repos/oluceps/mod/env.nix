{
  flake.modules.nixos.env =
    { config, pkgs, ... }:
    {
      environment = {
        defaultPackages = [ ];

        # srv.earlyoom.enable = true;
        systemPackages = [
          pkgs.eza
          pkgs.run0-sudo-shim
        ];

        etc = {
          "NIXOS".text = "";
          "machine-id" = {
            text = "b08dfa6083e7567a1921a715000001fb\n";
            mode = "0444";
          };
          "sbctl/sbctl.conf".source =
            let
              sbctlVar = "/var/lib/sbctl";
            in
            (pkgs.formats.yaml { }).generate "sbctl.conf" {
              bundles_db = "${sbctlVar}/bundles.json";
              db_additions = [ "microsoft" ];
              files_db = "${sbctlVar}/files.json";
              guid = "${sbctlVar}/GUID";
              keydir = "${sbctlVar}/keys";
              keys = {
                db = {
                  privkey = "${sbctlVar}/keys/db/db.key";
                  pubkey = "${sbctlVar}/keys/db/db.pem";
                  type = "file";
                };
                kek = {
                  privkey = "${sbctlVar}/keys/KEK/KEK.key";
                  pubkey = "${sbctlVar}/keys/KEK/KEK.pem";
                  type = "file";
                };
                pk = {
                  privkey = "${sbctlVar}/keys/PK/PK.key";
                  pubkey = "${sbctlVar}/keys/PK/PK.pem";
                  type = "file";
                };
              };
              landlock = true;
            };
        };
      };
      environment.sessionVariables = {
        # SYSTEMD_LOG_LEVEL = "debug";
        EDITOR = "hx";
        NIXOS_OZONE_WL = "1";
        # Steam needs this to find Proton-GE
        GOPATH = "\${HOME}/.cache/go";
        QT_IM_MODULES = "fcitx;wayland";
        # NIX_CFLAGS_COMPILE = "--verbose";
        # NIX_CFLAGS_LINK = "--verbose";
        # NIX_LDFLAGS = "--verbose";
        # WLR_RENDERER = "vulkan";
        PATH = [ "/home/${config.identity.user}/.npm-packages/bin" ];
        RAD_HOME = "/home/${config.identity.user}/.local/share/radicle";
        NTFY_AUTH_FILE = config.services.ntfy-sh.settings.auth-file or "";
        # LD_LIBRARY_PATH = [ "${lib.getLib pkgs.pcsclite}/lib" ];
        DIRENV_CONFIG = "/etc/direnv";

        CLAUDE_PACKAGE_MANAGER = "pnpm";
        CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse";
        CARGO_UNSTABLE_SPARSE_REGISTRY = "true";
        NEOVIDE_MULTIGRID = "1";
        NEOVIDE_WM_CLASS = "1";
        NODE_PATH = "~/.npm-packages/lib/node_modules";
        MOZ_USE_XINPUT2 = "1";
        RUSTIC_CACHE_DIR = "/var/cache/rustic";
      };

    };
}
