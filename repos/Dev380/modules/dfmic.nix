# NixOS module for dfmic: DeepFilterNet3_ll noise suppression as a PipeWire
# virtual microphone on the Intel NPU.
#
# It is a *user* service, because PipeWire, the session bus and the desktop are
# all per-user. Enabling the module installs the daemon and its unit; whether it
# starts at login remains `systemctl --user enable dfmic`, which `dfmic
# autostart on` and the window's switch both toggle.
{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  cfg = config.services.dfmic;

  # The model follows the package variant: the default package ships none and
  # downloads on request, `.override { withModels = true; }` carries the IR.
  # `models` decides, so a caller only has to set one of the two.
  package =
    if cfg.models == "download" && cfg.package.withModels
    then cfg.package.override {withModels = false;}
    else if cfg.models == "bundled" && !cfg.package.withModels
    then cfg.package.override {withModels = true;}
    else cfg.package;

  # Everything the daemon forks. `pw-metadata` handles the default-source
  # takeover and its startup recovery, curl + tar + gzip + sha256sum the model
  # download, and `systemctl` the window's unit queries. A user unit otherwise
  # gets NixOS's minimal default PATH, which has none of them; without
  # `pw-metadata` the daemon cannot restore the default source after an unclean
  # stop and refuses to start, which `Restart=on-failure` turns into a loop.
  servicePath = with pkgs; [pipewire curl coreutils gnutar gzip systemd];

  # `CAP_SYS_NICE` lets the NPU worker ask for realtime priority, shortening its
  # worst case from ~50 ms to ~20 ms. A user unit cannot hold AmbientCapabilities
  # (the user manager is unprivileged and the unit fails with
  # status=218/CAPABILITIES), so it is granted as a file capability on a wrapper.
  # `/run/wrappers/bin` precedes the PATH, so `dfmic run` in a terminal gets it
  # too.
  binary =
    if cfg.realtime
    then "/run/wrappers/bin/dfmic"
    else "${package}/bin/dfmic";
in {
  options.services.dfmic = {
    enable = lib.mkEnableOption "DeepFilterNet3_ll virtual microphone on the Intel NPU";

    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        The dfmic package to run. In a NUR flake this is
        `nur.repos.dev380.dfmic`; with the repository imported by path it is
        `(import ../nur-repo { inherit pkgs; }).dfmic`. Both carry no model and
        download it on request, unless `models = "bundled"` is set.
      '';
    };

    models = lib.mkOption {
      type = lib.types.enum [
        "download"
        "bundled"
      ];
      default = "download";
      description = ''
        Where the converted DeepFilterNet3_ll IR comes from.

        `download` (the default) keeps the ~18 MB of graphs out of the closure.
        The daemon fetches them on first use — `dfmic models download`, or the
        button in the window — into `$XDG_DATA_HOME/dfmic/models/<version>/`,
        verifying the archive with SHA-256. Until then the daemon runs and passes
        audio through unfiltered.

        `bundled` puts the same, hash-pinned graphs in the closure, so the daemon
        filters immediately and works offline. Pick it for a machine that is
        never online, at the cost of a larger closure and binary cache.

        This reconciles `package`: asking for `download` with a bundled package
        drops the bundle, and vice versa.
      '';
    };

    device = lib.mkOption {
      type = lib.types.str;
      default = "NPU";
      description = "OpenVINO device. There is deliberately no CPU fallback.";
    };

    source = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source";
      description = ''
        Physical source to capture from, by PipeWire node name. `null` follows
        the system default and persists the resolved choice on first run.
      '';
    };

    takeDefault = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Make the virtual microphone the default source while it is filtering, and
        give the previous default back when it stops. A default the user chooses
        by hand is honoured instead of being taken over again.
      '';
    };

    realtime = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Give the daemon `CAP_SYS_NICE` so its NPU worker can run at realtime
        priority, below PipeWire's own audio threads.

        This shortens the worker's worst case from ~50 ms to ~20 ms, buying
        margin against dropouts under load. It does not lower latency: the
        buffering floor comes from bursty hop production, not jitter.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [package];

    # The package's own user unit supplies Description, the [Install] section and
    # the restart policy; the drop-in below only overrides the argv and the
    # environment.
    systemd.packages = [package];

    security.wrappers.dfmic = lib.mkIf cfg.realtime {
      source = "${package}/bin/dfmic";
      owner = "root";
      group = "root";
      capabilities = "cap_sys_nice+ep";
    };

    # `path` is the declarative way to set a unit's PATH.
    # `utils.escapeSystemdExecArgs` quotes every argv element, so a source name
    # with spaces ("Built-in Audio Analog Stereo") stays one argument rather than
    # becoming a capture target plus four stray parameters.
    #
    # (`utils` is the NixOS special arg; `lib` has no escapeSystemdExecArgs.)
    systemd.user.services.dfmic = {
      overrideStrategy = "asDropin";
      path = servicePath;
      startLimitBurst = 5;
      startLimitIntervalSec = 60;
      serviceConfig.ExecStart = [
        ""
        (utils.escapeSystemdExecArgs (
          [binary "run" "--device" cfg.device]
          ++ lib.optional (package.modelsPath != null) "--models"
          ++ lib.optional (package.modelsPath != null) package.modelsPath
          ++ lib.optional (cfg.source != null) "--source"
          ++ lib.optional (cfg.source != null) cfg.source
          ++ lib.optional (!cfg.takeDefault) "--default-source"
          ++ lib.optional (!cfg.takeDefault) "never"
        ))
      ];
    };
  };
}
