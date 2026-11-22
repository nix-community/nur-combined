{ inputs, ... }:
let
  alpha = inputs.self.nixosConfigurations.alpha.config;
  alphaVM = alpha.virtualisation.vmVariant;
  wifiService = alpha.systemd.services.NetworkManager-ensure-profiles;
  wifiSecret = alpha.sops.secrets.wireless;
  wifiProfiles = alpha.networking.networkmanager.ensureProfiles.profiles;
  recovery = wifiProfiles.alpha-recovery;
in
# Recovery keeps DNS/DHCP on Wi-Fi; the server profile exposes only SSH globally.
assert alpha.networking.firewall.allowedTCPPorts == alpha.services.openssh.ports;
assert alpha.networking.firewall.allowedUDPPorts == [ ];
assert alpha.networking.firewall.interfaces.wlan0.allowedTCPPorts == [ 53 ];
assert
  alpha.networking.firewall.interfaces.wlan0.allowedUDPPorts == [
    53
    67
  ];
assert alpha.services.openssh.settings.AuthenticationMethods == "publickey";
assert alpha.services.openssh.settings.PermitRootLogin == "no";
assert !alpha.services.openssh.settings.PasswordAuthentication;
assert !alpha.services.openssh.settings.KbdInteractiveAuthentication;
assert !alpha.services.fwupd.enable;
assert !alphaVM.services.fwupd.enable;

# The physical Pi's profiles receive credentials only at runtime.
assert builtins.elem wifiSecret.path wifiService.serviceConfig.EnvironmentFile;
assert wifiSecret.format == "dotenv" && wifiSecret.key == "";
assert wifiSecret.owner == null || wifiSecret.owner == "root";
assert wifiSecret.uid == 0 && wifiSecret.mode == "0400";
assert builtins.elem "NetworkManager-ensure-profiles.service" wifiSecret.restartUnits;
assert wifiService.serviceConfig.UMask == "0177";
assert recovery.wifi.mode == "ap" && recovery.wifi.band == "bg";
assert recovery.wifi-security.psk == "$RECOVERY_PSK";
assert recovery.connection.autoconnect;
assert recovery.ipv4.address1 == "10.42.0.1/24";
assert alpha.networking.firewall.filterForward;
assert alpha.networking.networkmanager.settings.main.firewall-backend == "none";
assert builtins.all
  (
    name:
    let
      station = wifiProfiles.${name};
    in
    station.connection.autoconnect-priority > recovery.connection.autoconnect-priority
    && station.connection.autoconnect-retries == 1
    && !station.ipv4.may-fail
  )
  [
    "wifi-1"
    "wifi-2"
    "wifi-3"
    "wifi-4"
  ];
assert builtins.all
  (
    index:
    let
      primary = wifiProfiles."wifi-${toString index}";
      fallback = wifiProfiles."wifi-${toString (index + 2)}";
    in
    fallback.wifi.ssid == primary.wifi.ssid
    && fallback.wifi-security.psk == primary.wifi-security.psk
    && primary.wifi-security.pmf == 2
    && fallback.wifi-security.pmf == 1
    && fallback.connection.autoconnect-priority < primary.connection.autoconnect-priority
  )
  [
    1
    2
  ];

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

# Evaluate these derivations without making the VM closures CI build dependencies.
assert builtins.deepSeq [
  alpha.system.build.toplevel.drvPath
  alphaVM.system.build.vm.drvPath
] true;
true
