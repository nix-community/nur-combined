{
  callPackage,
  cutefish-toolkit,
  icu,
  libpng,
  pipewire,
  systemd,
}:

(callPackage ../cutefish/mk.nix { }) {
  pname = "cutefish-framework";

  postPatch = ''
    substituteInPlace clients/networkmanager/vpn_utils.cpp \
      --replace-fail '{"/etc/NetworkManager/VPN", "/usr/lib/NetworkManager/VPN"}' \
        '{"/etc/NetworkManager/VPN", "/run/current-system/sw/lib/NetworkManager/VPN", "/usr/lib/NetworkManager/VPN"}'
  '';

  extraBuildInputs = [
    cutefish-toolkit
    icu
    libpng
    pipewire
    systemd
  ];

  meta = {
    description = "System-service clients and file operations for the Cutefish desktop";
  };
}
