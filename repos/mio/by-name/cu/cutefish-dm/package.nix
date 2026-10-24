{
  mkCutefishDerivation,
  cutefish-toolkit,
  cutefish-compositor,
  pam,
}:

mkCutefishDerivation {
  pname = "cutefish-dm";

  postPatch = ''
    substituteInPlace daemon/config.h \
      --replace-fail '{"/usr/bin/cutefish-compositor", "--login"}' \
        '{"${cutefish-compositor}/bin/cutefish-compositor", "--login"}' \
      --replace-fail '{"/usr/local/share/wayland-sessions", "/usr/share/wayland-sessions"}' \
        '{"/run/current-system/sw/share/wayland-sessions", "/usr/share/wayland-sessions"}'
    substituteInPlace CMakeLists.txt \
      --replace-fail 'DESTINATION /usr/lib/systemd/system' 'DESTINATION lib/systemd/system' \
      --replace-fail 'DESTINATION /usr/lib/systemd/user/''${unit}.d' 'DESTINATION lib/systemd/user/''${unit}.d'
    substituteInPlace data/cutefish-dm.service \
      --replace-fail 'ExecStart=/usr/bin/cutefish-dm' "ExecStart=$out/bin/cutefish-dm"
    substituteInPlace helper/main.cpp \
      --replace-fail 'PATH=/usr/local/bin:/usr/bin:/bin' \
        'PATH=/run/wrappers/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin'
  '';

  extraBuildInputs = [
    cutefish-toolkit
    pam
  ];

  meta = {
    description = "Display manager for the Cutefish desktop";
    longDescription = ''
      The Wayland session also logs in through SDDM, GDM or LightDM.
      services.desktopManager.cutefish does not enable this display manager.
    '';
    mainProgram = "cutefish-dm";
  };
}
