{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.credentialsd;

  firefoxExtensionId = "credentialsd-helper@iinuwa.xyz";
  nativeMessagingHostName = "xyz.iinuwa.credentialsd_helper";
  nativeMessagingHostFile = "${nativeMessagingHostName}.json";
  chromiumNativeMessagingHost = pkgs.writeText "credentialsd-chromium-native-messaging-host.json" (
    builtins.toJSON {
      name = nativeMessagingHostName;
      description = "Helper for integrating browsers with credentialsd";
      path = "${cfg.package}/bin/credentialsd-firefox-helper";
      type = "stdio";
      allowed_origins = cfg.browserIntegration.chrome.allowedOrigins;
    }
  );
in
{
  options.services.credentialsd = {
    enable = lib.mkEnableOption "credentialsd";

    package = lib.mkPackageOption pkgs "credentialsd" { };

    portalPackage = lib.mkPackageOption pkgs "xdg-desktop-portal-HEAD" {
      extraDescription = ''
        It must provide the experimental Credential portal, which no
        xdg-desktop-portal release has yet. This replaces
        `pkgs.xdg-desktop-portal` for the whole system.
      '';
    };

    browserIntegration = {
      firefox.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to configure the Firefox native messaging host and
          force-install the credentialsd add-on.

          The add-on is unsigned, so it only installs in Firefox builds that
          honor `xpinstall.signatures.required = false`, such as Developer
          Edition and Nightly, in profiles with that preference set.
        '';
      };

      chrome = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to configure Chrome and Chromium native messaging hosts.";
        };

        allowedOrigins = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "chrome-extension://abcdefghijklmnopabcdefghijklmnop/" ];
          description = ''
            Chrome extension origins allowed to use the credentialsd native
            messaging host.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.dbus.packages = [ cfg.package ];
    systemd.packages = [ cfg.package ];
    systemd.user.services = {
      "xyz.iinuwa.credentialsd.Credentials".wantedBy = [ "default.target" ];
      "xyz.iinuwa.credentialsd.UiControl".wantedBy = [ "default.target" ];
      xdg-desktop-portal = {
        environment.XDG_DESKTOP_PORTAL_ENABLE_EXPERIMENTAL = "Credential";
        # An empty path stops NixOS from replacing the session PATH, which the
        # portal needs to launch applications by their bare Exec= names.
        path = lib.mkForce [ ];
      };
    };

    nixpkgs.overlays = [ (_: _: { xdg-desktop-portal = cfg.portalPackage; }) ];

    xdg.portal = {
      enable = true;
      extraPortals = [ cfg.package ];
      # The portal merges every config it finds, so this adds to the desktop's
      # own defaults. A desktop-specific xdg.portal.config.<desktop> takes this
      # file's place, and then needs this key as well.
      config.common."org.freedesktop.impl.portal.experimental.Credential" = "credentialsd";
    };

    programs.firefox = lib.mkIf cfg.browserIntegration.firefox.enable {
      nativeMessagingHosts.packages = [ cfg.package ];
      policies.ExtensionSettings.${firefoxExtensionId} = {
        installation_mode = "force_installed";
        install_url = "file://${cfg.package}/share/credentialsd/credentialsd-firefox-helper.xpi";
      };
    };

    environment.etc =
      lib.mkIf
        (cfg.browserIntegration.chrome.enable && cfg.browserIntegration.chrome.allowedOrigins != [ ])
        {
          "chromium/native-messaging-hosts/${nativeMessagingHostFile}".source = chromiumNativeMessagingHost;
          "opt/chrome/native-messaging-hosts/${nativeMessagingHostFile}".source = chromiumNativeMessagingHost;
        };

    warnings =
      lib.optional
        (cfg.browserIntegration.chrome.enable && cfg.browserIntegration.chrome.allowedOrigins == [ ])
        ''
          services.credentialsd.browserIntegration.chrome.enable is true, but
          services.credentialsd.browserIntegration.chrome.allowedOrigins is empty.
          Chrome and Chromium require explicit extension origins for native messaging.
        '';
  };
}
