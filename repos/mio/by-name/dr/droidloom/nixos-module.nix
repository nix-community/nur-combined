{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.droidloom;
  package = cfg.package;
  # The package ships the units upstream installs: one root service for the
  # privileged lifecycle daemon and the user units for the presenter and its
  # per-user brokers. Startup stays manual (`droidloomctl start`), so the user
  # units are installed but not enabled.
  userUnits = builtins.readDir "${package}/share/systemd/user";
in
{
  options.programs.droidloom = {
    enable = lib.mkEnableOption "Droidloom Android applications in native Wayland windows";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "Droidloom package providing the host runtime and Android image.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isx86_64;
        message = "Droidloom's prebuilt Android image in this repository is x86_64-only.";
      }
    ];

    environment.systemPackages = [ package ];

    boot.kernelModules = [ "binder_linux" ];
    boot.kernelParams = [ "psi=1" ];

    # Droidloom runs Android in namespaces on the host kernel, so the kernel
    # must provide Binder, user namespaces and seccomp.
    system.requiredKernelConfig = with config.lib.kernelConfig; [
      (isEnabled "ANDROID_BINDER_IPC")
      (isEnabled "ANDROID_BINDERFS")
      (isEnabled "USER_NS")
      (isEnabled "SECCOMP")
    ];

    systemd.units."droidloomd.service".text =
      builtins.readFile "${package}/lib/systemd/system/droidloomd.service";

    systemd.user.units = lib.mapAttrs' (
      name: _:
      lib.nameValuePair name {
        text = builtins.readFile "${package}/share/systemd/user/${name}";
      }
    ) userUnits;
  };
}
