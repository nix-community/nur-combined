{ inputs }:
let
  alpha = inputs.self.nixosConfigurations.alpha.config;
  alphaVM = alpha.virtualisation.vmVariant;
  pwnbox = inputs.self.nixosConfigurations.pwnbox.config;
  pwnboxVM = pwnbox.virtualisation.vmVariant;
  pwnboxDarwinVM =
    (inputs.self.nixosConfigurations.pwnbox.extendModules {
      modules = [
        {
          virtualisation.vmVariant.virtualisation.host.pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
        }
      ];
    }).config.virtualisation.vmVariant;
  standalone = inputs.self.homeConfigurations."iamanaws@pwnbox".config;
  wifiService = alpha.systemd.services.wpa_supplicant-wlan0;
  wifiSecret = alpha.sops.secrets.wireless;
in
# The physical Pi's encrypted Wi-Fi config must reach its unprivileged service.
assert inputs.nixpkgs.lib.hasInfix "-I ${wifiSecret.path}" wifiService.script;
assert builtins.elem wifiSecret.path wifiService.serviceConfig.BindReadOnlyPaths;
assert wifiSecret.group == wifiService.serviceConfig.Group;
assert wifiSecret.mode == "0440";

# The ARM guest uses the real host's users/services, without Pi hardware or secrets.
assert alphaVM.nixpkgs.hostPlatform.system == alpha.device.system;
assert alphaVM.nixpkgs.buildPlatform.system == "aarch64-linux";
assert alphaVM.virtualisation.host.pkgs.stdenv.hostPlatform.system == "x86_64-linux";
assert alphaVM.hardware.deviceTree.overlays == [ ];
assert alphaVM.boot.kernelPackages.kernel.pname != "linux-rpi";
assert !alphaVM.networking.wireless.enable;
assert (alphaVM.sops.secrets or { }) == { };
assert
  alphaVM.users.users.iamanaws.openssh.authorizedKeys.keys
  == alpha.users.users.iamanaws.openssh.authorizedKeys.keys;
assert alphaVM.services.openssh.ports == alpha.services.openssh.ports;

# Older Home Manager state versions must still render the shared Lua configuration.
assert pwnbox.home-manager.users.iamanaws.wayland.windowManager.hyprland.configType == "lua";
assert standalone.wayland.windowManager.hyprland.configType == "lua";
assert standalone.xdg.configFile ? "hypr/hyprland.lua";
# Let the QEMU module select the filesystem for its shared directory.
assert pwnboxVM.fileSystems."/mnt/hostshare".fsType == "virtiofs";
assert !pwnbox.virtualisation.virtualbox.guest.enable;

# A macOS launcher still runs the Linux guest, with Darwin-compatible host tools.
assert pwnboxDarwinVM.nixpkgs.hostPlatform.system == "x86_64-linux";
assert pwnboxDarwinVM.virtualisation.host.pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
assert pwnboxDarwinVM.fileSystems."/mnt/hostshare".fsType == "9p";
assert
  !builtins.any (inputs.nixpkgs.lib.hasInfix "-display gtk") pwnboxDarwinVM.virtualisation.qemu.options;
assert
  inputs.self.apps.aarch64-darwin.pwnbox.program
  == "${pwnboxDarwinVM.system.build.vm}/bin/run-pwnbox-vm";

# Evaluate these derivations without making the VM closures CI build dependencies.
assert builtins.deepSeq [
  alpha.system.build.toplevel.drvPath
  alphaVM.system.build.vm.drvPath
  pwnboxVM.system.build.vm.drvPath
  pwnboxDarwinVM.system.build.vm.drvPath
] true;
true
