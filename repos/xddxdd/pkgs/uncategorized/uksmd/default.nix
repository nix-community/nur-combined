{
  stdenv,
  sources,
  lib,
  meson,
  cmake,
  pkg-config,
  libcap_ng,
  systemd,
  ninja,
  procps,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.uksmd) pname version src;
  nativeBuildInputs = [
    meson
    cmake
    pkg-config
    ninja
  ];
  buildInputs = [
    libcap_ng
    procps
    systemd
  ];

  mesonFlags = [ "-Dlibalpm=disabled" ];

  postPatch = ''
    sed -i "s#install_dir: systemd_system_unit_dir#install_dir: '$out/lib/systemd/system'#g" meson.build
    sed -i "s#/usr/bin#$out/bin#g" meson.build
    sed -i "s#/usr/bin#$out/bin#g" uksmd.service
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Userspace KSM helper daemon";
    homepage = "https://github.com/CachyOS/uksmd";
    license = lib.licenses.gpl3Only;
    mainProgram = "uksmd";
    broken = true;
  };
})
