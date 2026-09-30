{
  gtk4-layer-shell,
  fetchFromGitHub,
  wrapGAppsHook4,
  pkg-config,
  libevdev,
  stdenv,
  gtkmm4,
  pam,
  lib,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "syslock";
  version = "unstable-2026-09-26";

  src = fetchFromGitHub {
    owner = "System64fumo";
    repo = "syslock";
    rev = "d50ff661ad9142a5f1959b46e7a85d2fd621341d";
    hash = "sha256-94HFPduHrxyuJYVscAqWKDWITiyrYD47+5jIbCC44WI=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    pkg-config
  ];

  buildInputs = [
    gtk4-layer-shell
    gtkmm4
    libevdev
    pam
  ];

  postPatch = ''
        cat > src/git_info.hpp <<EOF
    #define GIT_COMMIT_MESSAGE "${finalAttrs.src.rev}"
    #define GIT_COMMIT_DATE "${lib.removePrefix "unstable-" finalAttrs.version}"
    EOF
  '';

  patches = [./auto-monitor.patch];

  NIX_CFLAGS_COMPILE = "-fexceptions";

  installPhase = ''
    runHook preInstall
    install -Dm755 build/syslock $out/bin/syslock
    install -Dm755 build/libsyslock.so $out/lib/libsyslock.so
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/syslock \
      --set LD_LIBRARY_PATH $out/lib
  '';

  meta = {
    homepage = "https://github.com/System64fumo/syslock";
    description = "Simple screen locker for Wayland written in gtkmm4";
    mainProgram = "syslock";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux;
    sourceProvenance = [lib.sourceTypes.fromSource];
  };
})
