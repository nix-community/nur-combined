{
  gtk4-layer-shell,
  fetchFromGitHub,
  wayland-scanner,
  wrapGAppsHook4,
  wireplumber,
  pkg-config,
  playerctl,
  jsoncpp,
  wayland,
  procps,
  stdenv,
  gtkmm4,
  libnl,
  curl,
  dbus,
  lib,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sysbar";
  version = "unstable-2026-08-12";

  src = fetchFromGitHub {
    owner = "System64fumo";
    repo = "sysbar";
    rev = "03534d3c17f1711b48d80e6b51d9201959f17d4e";
    hash = "sha256-eJ83dzLcbqfJV5+jskSXmy0b0ESk1vJ1lSzMJ/w/kss=";
  };

  nativeBuildInputs = [
    wayland-scanner
    wrapGAppsHook4
    pkg-config
  ];

  buildInputs = [
    gtk4-layer-shell
    wireplumber
    playerctl
    jsoncpp
    wayland
    gtkmm4
    libnl
    curl
    dbus
  ];

  postPatch = ''
        substituteInPlace Makefile \
          --replace-fail 'CXXFLAGS += -I /usr/include/libnl3/ -lnl-3 -lnl-genl-3' \
          'PKGS += libnl-3.0 libnl-genl-3.0'

        substituteInPlace src/main.cpp src/window.cpp \
          --replace-fail '/usr/share/sys64/bar' "$out/share/sys64/bar"

        cat > src/git_info.hpp <<EOF
    #define GIT_COMMIT_MESSAGE "${finalAttrs.src.rev}"
    #define GIT_COMMIT_DATE "${lib.removePrefix "unstable-" finalAttrs.version}"
    EOF
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/sysbar $out/bin/sysbar
    install -Dm755 build/libsysbar.so $out/lib/libsysbar.so
    install -Dm644 config.conf style.css events.css calendar.conf -t $out/share/sys64/bar
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/sysbar \
      --set LD_LIBRARY_PATH $out/lib \
      --prefix PATH : ${lib.makeBinPath [procps]}
  '';

  meta = {
    homepage = "https://github.com/System64fumo/sysbar";
    description = "Modular status bar for Wayland written in gtkmm4";
    mainProgram = "sysbar";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux;
    sourceProvenance = [lib.sourceTypes.fromSource];
  };
})
