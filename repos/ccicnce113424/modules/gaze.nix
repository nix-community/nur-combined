# NixOS module for Gaze: the `gazed` daemon, its D-Bus and polkit policies, the
# PAM integration, and the desktop integrations that come as separate packages.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.gaze;
  pam = config.security.pam;

  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "gaze-config.toml" cfg.settings;

  pamModule = "${cfg.package}/lib/security/pam_gaze.so";
  pamPackage = pam.package;

  # Services below own their whole stack, the same way nixpkgs writes
  # `gdm-password` and the Plasma biometric slots: `useDefaultRules = false`
  # plus explicit rules, so `order` is a local number instead of a nixpkgs rule
  # number that can move between releases.
  orderedRules =
    rules:
    lib.listToAttrs (
      lib.imap0 (
        index: rule:
        # The rule name is the attribute key; `name` itself is read-only.
        lib.nameValuePair rule.name (removeAttrs rule [ "name" ] // { order = index * 100; })
      ) rules
    );

  mkPamService =
    {
      auth,
      account,
      password ? [ ],
      session ? [ ],
    }:
    {
      useDefaultRules = false;
      rules = {
        auth = orderedRules auth;
        account = orderedRules account;
        password = orderedRules password;
        session = orderedRules session;
      };
    };

  rule = name: modulePath: control: {
    inherit name control modulePath;
  };

  # A biometric slot a desktop greeter starts up front: face-only and
  # sequential, since nothing answers a prompt there, and with the account gates
  # in front because a `done` match ends the authentication stack. A fingerprint
  # reader shares the slot and runs after Gaze.
  biometricSlot =
    {
      shareWithReader ? false,
    }:
    mkPamService {
      auth = [
        (rule "nologin" "${pamPackage}/lib/security/pam_nologin.so" "requisite")
        (
          rule "faillock" "${pamPackage}/lib/security/pam_faillock.so" "requisite"
          // {
            args = [ "preauth" ];
          }
        )
        (rule "gaze" pamModule "[success=done default=ignore]")
      ]
      ++ lib.optional shareWithReader (
        rule "fprintd" "${config.services.fprintd.package}/lib/security/pam_fprintd.so" "sufficient"
      )
      ++ [ (rule "deny" "${pamPackage}/lib/security/pam_deny.so" "required") ];
      account = [ (rule "permit" "${pamPackage}/lib/security/pam_permit.so" "required") ];
      password = [ (rule "deny" "${pamPackage}/lib/security/pam_deny.so" "required") ];
      session = [ (rule "permit" "${pamPackage}/lib/security/pam_permit.so" "required") ];
    };
in
{
  options.services.gaze = {
    enable = lib.mkEnableOption "Gaze face authentication";

    package = lib.mkPackageOption pkgs "gaze" {
      extraDescription = "It provides the `gazed` daemon, the `gaze` CLI, and the PAM modules.";
    };

    settings = lib.mkOption {
      inherit (settingsFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          security.level = "high";
          auth.require_confirmation_lock_screen = true;
        }
      '';
      description = ''
        Runtime options for {file}`/etc/gaze/config.toml`, documented at
        <https://gaze.gundulabs.com/guide/configuration>. Anything left out
        keeps the daemon's built-in default.

        The module defaults `storage.encrypt_templates` to true, because that is
        what the configuration the package ships opts into while the daemon
        itself defaults to plain text. Set it to `false` to accept plain-text
        templates; the daemon then also refuses the keyring unlock options.
        Enabling {option}`services.gaze.kde.unlockKwallet` enables
        `storage.unlock_kwallet` here.
      '';
    };

    mutableConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether {file}`/etc/gaze/config.toml` stays writable.

        When true, the file is seeded from {option}`services.gaze.settings` only
        if it does not exist yet, so the GUI's settings page and
        {command}`gaze config` can change it and later changes to
        {option}`services.gaze.settings` are ignored. Set this to false to make
        the file a read-only link to the generated configuration, which also
        makes the daemon reject runtime configuration changes.
      '';
    };

    pam.defaultServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "sudo"
        "polkit-1"
      ];
      example = [
        "sudo"
        "polkit-1"
        "login"
      ];
      description = ''
        PAM services that attempt face authentication without further
        configuration. Each entry only defaults
        {option}`security.pam.services.<name>.gaze.enable` to true, so a single
        service can still be turned off by setting it to false.
      '';
    };

    tpm.tcti = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "device:/dev/tpm0";
      description = ''
        `TPM2TOOLS_TCTI` connection string used to seal the encryption key of
        stored face templates. When null the daemon prefers
        {file}`/dev/tpmrm0` and falls back to {file}`/dev/tpm0`. Set this only to
        reach a TPM through something else, for example `tabrmd`.
      '';
    };

    gui = {
      enable = lib.mkEnableOption "the Gaze GTK4/Adwaita configuration and enrollment GUI";

      package = lib.mkPackageOption pkgs "gaze-gui" { };
    };

    gnome = {
      enable = lib.mkEnableOption "the Gaze GNOME Shell extension" // {
        description = ''
          Installs the extension and turns it on for every GNOME session, see
          {option}`services.gaze.gnome.enableForUsers`. Face authentication at
          the login screen stays a separate, opt-in switch.
        '';
      };

      extensionPackage = lib.mkPackageOption pkgs "gaze-gnome-extension" { };

      enableForUsers = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Load the extension and turn on face unlock in every GNOME user
          session, by writing dconf defaults into the `user` profile. Without
          this the extension is only installed and every user has to enable it
          in the Extensions app first.

          These are defaults rather than locks, so a user who turns the
          extension or the feature off keeps that choice. Set this to false if
          you manage `org/gnome/shell` `enabled-extensions` yourself, through
          home-manager or your own {option}`programs.dconf.profiles.user`
          database: two databases that set the same key shadow each other
          instead of merging, and only the first one listed takes effect.
        '';
      };

      gdmFaceLogin = lib.mkEnableOption ''
        face authentication at the GDM login screen itself, not only on the lock
        screen. Password login stays available as a fallback, see
        <https://gaze.gundulabs.com/guide/gnome>
      '';
    };

    kde = {
      lockScreen = lib.mkEnableOption ''
        hands-free face unlock on the KDE Plasma lock screen. KScreenLocker
        starts the biometric PAM slots alongside the password field, so face
        authentication begins without any key press. Gaze takes
        `kde-fingerprint`, or `kde-smartcard` when a fingerprint reader already
        owns the first, so face and finger race instead of queueing. The
        equivalent of the `gaze-kde` package's lock screen wiring
      '';

      loginScreen = lib.mkEnableOption ''
        face authentication in the Plasma Login Manager and SDDM login stack.
        Both authenticate through the `login` PAM service, so the rule is added
        there; on a greeter without an up-front biometric service it only runs
        once the login form is submitted, exactly as a fingerprint reader does
        there. It applies to console logins on a virtual terminal as well.
        KWallet asks for its password after a face login unless
        {option}`services.gaze.kde.unlockKwallet` is enabled
      '';

      unlockKwallet = lib.mkEnableOption ''
        KWallet credential handoff after a KDE face login. Requires
        {option}`services.gaze.kde.loginScreen` and sequential PAM
        authentication. Enabling it sets the runtime opt-in
        (`storage.unlock_kwallet`) in {option}`services.gaze.settings`, since the
        daemon only releases the credential with that, sealed templates, and
        liveness on. Like every setting it only seeds a configuration file that
        does not exist yet, and it does not enroll a credential, so
        {command}`gaze keyring --kwallet` is still needed once
      '';
    };
  };

  # The per-service knob lives on the nixpkgs PAM submodule, next to
  # `fprintAuth` and `howdy`. Only the type may be redeclared here, since a
  # `default`, `example`, or `description` would collide with the declaration in
  # `nixos/modules/security/pam.nix`.
  options.security.pam.services = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        let
          authRules = config.rules.auth;

          unixOrder = authRules.unix.order or null;
          fprintdOrder = authRules.fprintd.order or null;

          # Gaze runs ahead of everything that can end the authentication stack,
          # so the fingerprint reader and the password stay as fallbacks.
          # nixpkgs numbers its built-in rules in the tens of thousands and moves
          # those numbers between releases, so offset from the rule Gaze has to
          # precede instead of using a constant.
          precedeOrder =
            let
              anchors = lib.filter (anchor: anchor != null) [
                unixOrder
                fprintdOrder
              ];
            in
            if anchors == [ ] then 10000 else lib.foldl' lib.min (lib.head anchors) anchors;

          gazeOrder = if config.gaze.order != null then config.gaze.order else precedeOrder - 10;

          # KWallet is handed the credential Gaze puts into the PAM token, so the
          # rules that carry it sit directly behind the gaze rule. Both SDDM and
          # the Plasma Login Manager only authenticate through `login`.
          kwalletLogin = cfg.enable && cfg.kde.unlockKwallet && name == "login";
          kwalletModule = "${config.kwallet.package}/lib/security/pam_kwallet5.so";
          permitModule = "${pamPackage}/lib/security/pam_permit.so";
        in
        {
          options.gaze = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = cfg.enable && lib.elem name cfg.pam.defaultServices;
              defaultText = lib.literalExpression ''
                config.services.gaze.enable
                && lib.elem name config.services.gaze.pam.defaultServices
              '';
              description = ''
                Whether this PAM service attempts face authentication. The rule
                is inserted ahead of `pam_fprintd` and `pam_unix`, so face
                authentication is tried first and both the fingerprint reader
                and the password remain usable.
              '';
            };

            control = lib.mkOption {
              type = lib.types.str;
              default = "sufficient";
              description = ''
                PAM control field for the gaze rule. `sufficient` lets a face
                match end the authentication instead of asking for a password.
              '';
            };

            simultaneous = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                Pass `simultaneous` to the module, running face authentication
                and the password prompt at the same time, instead of trying the
                face first.
              '';
            };

            retry = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                Add a second gaze rule below the password module, which gives
                face authentication one more attempt after a rejected password.
                It stands down without using the camera when the first pass
                already decided that the face was not a match. Requires the
                password module not to be `required`.
              '';
            };

            order = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              example = lib.literalExpression "config.security.pam.services.login.rules.auth.unix.order + 10";
              description = ''
                Explicit `order` of the gaze rule. When null, the rule is placed
                ahead of both `pam_fprintd` and `pam_unix`. Set this to reorder
                Gaze relative to another rule, offsetting from that rule's own
                `order` rather than from a constant.
              '';
            };
          };

          config = {
            # The nixpkgs KWallet hooks cover the password path: the auth hook
            # stores the password typed at the prompt and the session hook starts
            # the wallet. The gaze rules below cover the face path.
            kwallet.enable = lib.mkIf kwalletLogin (lib.mkDefault true);

            rules.auth.gaze = lib.mkIf config.gaze.enable {
              order = lib.mkDefault gazeOrder;
              # A face match skips the next rule and lands on the KWallet rule,
              # which saves the credential, before authentication ends. Anything
              # else jumps over both of those and reaches the original stack, so
              # the password stays available.
              control = lib.mkDefault (
                if kwalletLogin then "[success=1 default=ignore]" else config.gaze.control
              );
              modulePath = lib.mkDefault pamModule;
              args =
                lib.optional config.gaze.simultaneous "simultaneous" ++ lib.optional kwalletLogin "kde-login";
            };

            rules.auth.gazeKwalletSkip = lib.mkIf (kwalletLogin && config.gaze.enable) {
              order = gazeOrder + 1;
              control = "[success=2 default=ignore]";
              modulePath = permitModule;
            };

            rules.auth.gazeKwallet = lib.mkIf (kwalletLogin && config.gaze.enable) {
              order = gazeOrder + 2;
              control = "optional";
              modulePath = kwalletModule;
            };

            rules.auth.gazeKwalletDone = lib.mkIf (kwalletLogin && config.gaze.enable) {
              order = gazeOrder + 3;
              control = "[success=done default=ignore]";
              modulePath = permitModule;
            };

            # Reached only after the password module rejected the password.
            rules.auth.gazeRetry = lib.mkIf (config.gaze.enable && config.gaze.retry) {
              order = if unixOrder == null then gazeOrder + 1000 else unixOrder + 10;
              control = config.gaze.control;
              modulePath = pamModule;
              args = [ "retry" ];
            };
          };
        }
      )
    );
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.kde.unlockKwallet {
        assertions = [
          {
            assertion = cfg.kde.loginScreen;
            message = "services.gaze.kde.unlockKwallet requires services.gaze.kde.loginScreen.";
          }
          {
            assertion =
              let
                gaze = config.security.pam.services.login.gaze;
              in
              !gaze.enable || (!gaze.simultaneous && !gaze.retry && gaze.control == "sufficient");
            message = "services.gaze.kde.unlockKwallet requires sequential, sufficient Gaze authentication without retry for the login service.";
          }
        ];
      })

      {
        environment.systemPackages = [ cfg.package ];

        # Ships the com.gundulabs.Gaze system bus policy.
        services.dbus.packages = [ cfg.package ];

        # Enrollment and configuration changes are authorized through polkit;
        # enabling it also links $out/share/polkit-1 into the system profile.
        security.polkit.enable = true;

        systemd.services.gazed = {
          description = "Gaze face authentication daemon";
          documentation = [ "https://gaze.gundulabs.com/guide/installation" ];
          # Mirrors the daemon's own unit file, packaging/config/gazed.service.
          after = [ "dbus.service" ];
          requires = [ "dbus.service" ];
          wantedBy = [ "multi-user.target" ];
          startLimitIntervalSec = 60;
          startLimitBurst = 5;
          environment = {
            XDG_CACHE_HOME = "/var/cache/gaze";
            TPM2TOOLS_TCTI = lib.mkIf (cfg.tpm.tcti != null) cfg.tpm.tcti;
          };
          serviceConfig = {
            ExecStart = "${lib.getBin cfg.package}/bin/gazed";
            Restart = "on-failure";
            RestartSec = 5;
            # 78 is gaze_core::cpu::EXIT_UNSUPPORTED_CPU (the CPU has no AVX2):
            # restarting can only reproduce the same exit.
            RestartPreventExitStatus = 78;
            StateDirectory = "gaze";
            StateDirectoryMode = "0700";
            CacheDirectory = "gaze";
            UMask = "0077";
            LimitCORE = 0;
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            InaccessiblePaths = [
              "/home"
              "/root"
            ];
            ProtectClock = true;
            ProtectHostname = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
            ProtectKernelLogs = true;
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            LockPersonality = true;
            SystemCallArchitectures = "native";
            # Only D-Bus (AF_UNIX), netlink (udev, logind), and IP for the model
            # downloads.
            RestrictAddressFamilies = [
              "AF_UNIX"
              "AF_NETLINK"
              "AF_INET"
              "AF_INET6"
            ];
            SystemCallFilter = "@system-service";
            SystemCallErrorNumber = "EPERM";
            # No ProtectProc: the SSH heuristic walks /proc/<pid>/environ and
            # comm up the caller chain, which needs other processes visible.
            CapabilityBoundingSet = [
              "CAP_DAC_READ_SEARCH"
              "CAP_DAC_OVERRIDE"
            ];
            # The daemon rewrites config.toml for the GUI, and the GNOME
            # extension toggles face login in the gdm dconf database.
            ReadWritePaths = [
              "-/etc/gaze"
              "-/etc/dconf/db"
            ];
            # IR cameras need read/write access to their /dev/video* node, and
            # sealing the template key needs the TPM resource manager.
            SupplementaryGroups = [
              "video"
            ]
            ++ lib.optional config.security.tpm2.enable config.security.tpm2.tssGroup;
          };
        };
      }

      {
        systemd.tmpfiles.rules = lib.mkIf cfg.mutableConfig [
          "d /etc/gaze 0755 root root -"
          "C /etc/gaze/config.toml 0644 root root - ${configFile}"
        ];

        environment.etc."gaze/config.toml" = lib.mkIf (!cfg.mutableConfig) {
          source = configFile;
        };
      }

      (lib.mkIf cfg.gui.enable {
        environment.systemPackages = [ cfg.gui.package ];
      })

      (lib.mkIf cfg.gnome.enable {
        environment.systemPackages = [ cfg.gnome.extensionPackage ];
        # GNOME Shell and its greeter only scan $XDG_DATA_DIRS/share/gnome-shell.
        environment.pathsToLink = [ "/share/gnome-shell" ];
        # The daemon reads the GDM face-login switch out of the gdm profile.
        systemd.services.gazed.path = [ pkgs.dconf ];
        programs.dconf.enable = true;
        programs.dconf.profiles.gdm.databases = [
          {
            settings = {
              "org/gnome/shell".enabled-extensions = [
                cfg.gnome.extensionPackage.passthru.extensionUuid
              ];
              "org/gnome/shell".disable-user-extensions = false;
              "org/gnome/shell/extensions/gaze".enable-face-authentication = cfg.gnome.gdmFaceLogin;
            };
          }
        ];

        programs.dconf.profiles.user.databases = lib.mkIf cfg.gnome.enableForUsers [
          {
            settings = {
              "org/gnome/shell".enabled-extensions = [
                cfg.gnome.extensionPackage.passthru.extensionUuid
              ];
              "org/gnome/shell/extensions/gaze".enable-face-authentication = true;
            };
          }
        ];

        # Face-only service the extension runs at the login screen; the password
        # stays available through `gdm-password`, which GDM runs in parallel.
        # Mirrors packaging/pam/gdm-face.arch.
        security.pam.services."gdm-face" = mkPamService {
          auth = [
            (rule "env" "${pamPackage}/lib/security/pam_env.so" "required")
            (rule "gaze" pamModule "[success=1 default=ignore]")
            (rule "deny" "${pamPackage}/lib/security/pam_deny.so" "requisite")
            (rule "permit" "${pamPackage}/lib/security/pam_permit.so" "required")
            (
              rule "gnome_keyring" "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so" "optional"
              // {
                args = [ "use_authtok" ];
              }
            )
          ];
          account = [
            (rule "nologin" "${pamPackage}/lib/security/pam_nologin.so" "required")
            (rule "unix" pam.pam_unixModulePath "required")
          ];
          password = [ (rule "deny" "${pamPackage}/lib/security/pam_deny.so" "required") ];
          session = [
            (
              rule "env" "${pamPackage}/lib/security/pam_env.so" "required"
              // {
                settings = {
                  conffile = "/etc/pam/environment";
                  readenv = 0;
                };
              }
            )
            (rule "unix" pam.pam_unixModulePath "required")
            (rule "systemd" "${config.systemd.package}/lib/security/pam_systemd.so" "required")
            (
              rule "gnome_keyring" "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so" "optional"
              // {
                args = [ "auto_start" ];
              }
            )
          ];
        };
      })

      (lib.mkIf cfg.kde.lockScreen (
        let
          # nixpkgs configures these two slots from fprintd and p11, so Gaze stays
          # out of the way when a fingerprint reader owns the first one.
          readerOwnsFingerprintSlot = config.services.fprintd.enable;
          smartcardSlotExists = config.security.pam.p11.enable;

          # `pam_fprintd` blocks for its whole timeout, so sharing a slot starves
          # whichever module runs second. Prefer the free slot when there is one.
          slot =
            if readerOwnsFingerprintSlot && !smartcardSlotExists then "kde-smartcard" else "kde-fingerprint";
          shareWithReader = slot == "kde-fingerprint" && readerOwnsFingerprintSlot;
        in
        {
          security.pam.services.${slot} = biometricSlot { inherit shareWithReader; };

          # The interactive `kde` service would otherwise claim the camera at the
          # same time as the biometric slot.
          security.pam.services.kde.gaze.enable = lib.mkDefault false;
        }
      ))

      # The configuration the package ships opts into TPM-sealed templates while
      # the daemon defaults to plaintext, so keep the package's choice. Set
      # `storage.encrypt_templates` to false for plaintext templates; the daemon
      # then also refuses the keyring unlock options.
      {
        services.gaze.settings.storage.encrypt_templates = lib.mkDefault true;
      }

      # The runtime half of the KWallet handoff: wiring PAM alone releases
      # nothing. The daemon also requires sealed templates (above) and liveness
      # (on by default).
      (lib.mkIf cfg.kde.unlockKwallet {
        services.gaze.settings.storage.unlock_kwallet = lib.mkDefault true;
      })

      (lib.mkIf cfg.kde.loginScreen {
        # The Plasma Login Manager and SDDM only `substack login`, so this one
        # rule covers both of them as well as console logins, on submission.
        security.pam.services.login.gaze.enable = lib.mkDefault true;

        # The greeter's own up-front biometric slot (plasma-login-manager!185) is
        # deliberately not declared: no Plasma Login Manager version starts it
        # yet, and nixpkgs may define the service itself once one does, which
        # would then merge with our rules. When such a greeter ships, it is
        # `security.pam.services."plasmalogin-fingerprint" = biometricSlot { ... }`.
      })
    ]
  );
}
