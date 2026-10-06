{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.miodroid-rootless;
  wipWarning = "programs.miodroid-rootless is experimental: enable virtualisation.miodroid-rootless on the host, add this user to the NixOS rootless group and lxc-user, and enable users.users.<name>.autoSubUidGidRange = true.";

  env = [
    "MIODROID_ROOTLESS=1"
    "MIODROID_WORK=${cfg.workDirectory}"
  ]
  ++ lib.optional (cfg.instance != null) "MIODROID_INSTANCE=${cfg.instance}"
  ++ lib.optional (cfg.imageStrategy == "overlay") "MIODROID_ROOTLESS_OVERLAY=1";

  # The image bundle is a store path, so it changes whenever the bundle does:
  # stamp the copy and only re-install the images when it actually differs,
  # instead of copying gigabytes on every session start.
  installImages = pkgs.writeShellScript "miodroid-install-images" ''
    set -eu

    bundle=${lib.escapeShellArg (toString cfg.imagePackage)}
    images=${lib.escapeShellArg "${cfg.workDirectory}/images"}
    stamp="$images/.bundle"

    if [ -s "$stamp" ] && [ "$(cat "$stamp")" = "$bundle" ]; then
      exit 0
    fi

    ${pkgs.coreutils}/bin/install -d "$images"
    ${pkgs.coreutils}/bin/install -m 0644 "$bundle/system.img" "$images/system.img"
    ${pkgs.coreutils}/bin/install -m 0644 "$bundle/vendor.img" "$images/vendor.img"
    printf '%s\n' "$bundle" > "$stamp"
  '';
in
{
  options.programs.miodroid-rootless = {
    enable = lib.mkEnableOption "experimental rootless Miodroid";
    package = lib.mkPackageOption pkgs "miodroid" { };
    imagePackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      example = lib.literalExpression "pkgs.miodroid-images.a16";
      description = ''
        Declarative system.img and vendor.img bundle to make available in
        the rootless Miodroid work directory. When null, use the normal OTA
        workflow.
      '';
    };
    workDirectory = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.dataHome}/miodroid";
      defaultText = lib.literalExpression ''"\${config.xdg.dataHome}/miodroid"'';
      description = ''
        Writable work directory for the experimental rootless Miodroid
        instance: the images, LXC configuration and the instance's Android
        userdata ({file}`<workDirectory>/data`) all live here, so this is what
        decides which instance you are talking to. Changing it makes Android
        start from an empty userdata directory.
      '';
    };
    instance = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional named Miodroid instance.";
    };
    session.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Start the Miodroid session, the per-user daemon that owns
        `id.miodro.Session` and connects Android to the Wayland and
        PulseAudio sockets. Without it the container runs but no Android
        app can be launched.
      '';
    };
    hostHelperService = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      defaultText = lib.literalExpression "null";
      description = ''
        NixOS system service that prepares host devices for rootless
        Miodroid, if the host mounts binderfs for its containers
        (`virtualisation.miodroid-rootless.hostBinderfs` on the host). Leave
        null when the container mounts its own binderfs, which is the
        default.
      '';
    };
    imageStrategy = lib.mkOption {
      type = lib.types.enum [
        "grow"
        "overlay"
      ];
      default = "grow";
      description = ''
        How the rootless container gets a writable Android system and vendor
        image: `grow` copies and enlarges the OTA images and mounts them
        read-write, `overlay` mounts them read-only and puts a fuse-overlayfs
        overlay on top for the writes.

        This has to match `virtualisation.miodroid-rootless.imageStrategy` on
        the host, because this is the unit that starts the container.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.warn wipWarning {
      home.packages = [ cfg.package ];

      systemd.user.services.miodroid-container = {
        Unit = {
          Description = "Experimental Rootless Miodroid Container";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre =
            lib.optional (
              cfg.hostHelperService != null
            ) "${pkgs.systemd}/bin/systemctl --system is-active --quiet ${cfg.hostHelperService}"
            ++ lib.optional (cfg.imagePackage != null) (toString installImages);
          ExecStart = "${cfg.package}/bin/miodroid container start";
          Environment = env;
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      systemd.user.services.miodroid-session = lib.mkIf cfg.session.enable {
        Unit = {
          Description = "Experimental Rootless Miodroid Session";
          Requires = [ "miodroid-container.service" ];
          After = [
            "miodroid-container.service"
            "graphical-session.target"
          ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${cfg.package}/bin/miodroid session start";
          Environment = env;
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    }
  );
}
