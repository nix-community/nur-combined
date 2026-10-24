{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
  cutefish-toolkit,
  cutefish-compositor,
  pam,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-dm";
  version = cu.version "2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "cutefish-dm";
    rev = "73ed274f3ec27af8e4e118f428073769fc4e873a";
    hash = "sha256-eg3oh55IqlOKhX0nneuDaYnRjrE8Zzz/UWPyly3ao/E=";
  };

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

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    pam
  ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "Cutefish display manager. The desktop session also logs in through SDDM, GDM or LightDM";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-dm";
  };
}
