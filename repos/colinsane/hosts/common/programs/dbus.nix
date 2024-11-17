{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.dissent;
in
{
  sane.programs.dbus = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    packageUnwrapped = (pkgs.dbus.override {
      # remove features i don't want. mostly to avoid undesired interactions, but also it reduces the closure by 55 MB :)
      enableSystemd = false;
      x11Support = false;
    }).overrideAttrs (upstream: {
      postFixup = (upstream.postFixup or "") + ''
        # the XML docs have a URI field which points to self,
        # and that breaks the sandbox checker
        substituteInPlace $out/share/xml/dbus-1/catalog.xml \
          --replace-fail "$out" "/run/current-system/sw"

        # conf file points to dbus-daemon-launch-helper by absolute path,
        # which breaks sandboxing. i don't want dbus auto-launching stuff anyway though.
        substituteInPlace $out/share/dbus-1/system.conf \
          --replace-fail "$out/libexec/dbus-daemon-launch-helper" "false"
      '';
    });

    sandbox.extraRuntimePaths = [
      "dbus"
    ];
    sandbox.keepPids = true;   #< not actually sure *why* this is necessary, but it is

    env.DBUS_SESSION_BUS_ADDRESS = "unix:path=$XDG_RUNTIME_DIR/dbus/bus";

    # normally systemd would create a dbus session for us, but if you configure it not to do that
    # then we can create our own. not sure if there's a dependency ordering issue here: lots
    # of things depend on dbus but i don't do anything special to guarantee this is initialized
    # before them.
    services.dbus-user = {
      description = "dbus user session";
      partOf = lib.mkIf cfg.config.autostart [ "default" ];
      command = pkgs.writeShellScript "dbus-start" ''
        # have to create the dbus directory before launching so that it's available in the sandbox
        mkdir -p "$XDG_RUNTIME_DIR/dbus"
        dbus-daemon --session --nofork --address="$DBUS_SESSION_BUS_ADDRESS"
      '';
      readiness.waitExists = [ "$XDG_RUNTIME_DIR/dbus/bus" ];
    };
  };
}
