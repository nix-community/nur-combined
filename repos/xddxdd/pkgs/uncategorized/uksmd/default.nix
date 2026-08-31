{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
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
  pname = "uksmd";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "CachyOS";
    repo = "uksmd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-77Q0rF0xyhArP+8n0fXVUSVezzuwKAAABjA8W1dsI9w=";
  };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Userspace KSM helper daemon";
    homepage = "https://github.com/CachyOS/uksmd";
    license = lib.licenses.gpl3Only;
    mainProgram = "uksmd";
    broken = true;
  };
})
