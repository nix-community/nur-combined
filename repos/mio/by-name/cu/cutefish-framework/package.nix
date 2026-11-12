{
  mkCutefishDerivation,
  cutefish-toolkit,
  icu,
  libpng,
  pipewire,
  systemd,
}:

mkCutefishDerivation {
  pname = "cutefish-framework";

  postPatch = ''
    substituteInPlace clients/networkmanager/vpn_utils.cpp \
      --replace-fail '{"/etc/NetworkManager/VPN", "/usr/lib/NetworkManager/VPN"}' \
        '{"/etc/NetworkManager/VPN", "/run/current-system/sw/lib/NetworkManager/VPN", "/usr/lib/NetworkManager/VPN"}'
    # Preset avatars are installed by cutefish-wallpapers and linked into the
    # system profile; the header's default directory is the upstream /usr one.
    substituteInPlace clients/accounts/account_picture.h \
      --replace-fail '"/usr/share/cutefish/avatars"' \
        '"/run/current-system/sw/share/cutefish/avatars"'
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
