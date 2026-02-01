{
  lib,
  stdenv,
  fetchgit,
  cmake,
  pkg-config,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook3,
  makeBinaryWrapper,
}:

stdenv.mkDerivation rec {
  pname = "icloud-for-linux";
  version = "0.26";

  src = fetchgit {
    url = "https://github.com/cross-platform/icloud-for-linux.git";
    rev = "7ae687e7d5856ea80ab740450ca7ea3a041ac10f";
    hash = "sha256-dLEzAY7ovBgI47c3Zr20KuwR1wsBdP1T5RgQ0Q0R0HI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    makeBinaryWrapper
  ];

  buildInputs = [
    gtk3
    webkitgtk_4_1
  ];

  postPatch = ''
    # Newer nixpkgs exposes WebKitGTK as webkit2gtk-4.1 only.
    substituteInPlace CMakeLists.txt \
      --replace-fail "webkit2gtk-4.0" "webkit2gtk-4.1"
  '';

  installPhase = ''
    runHook preInstall

    cmake --install . --prefix "$out"

    apps=(
      "mail:mail:Mail"
      "contacts:contacts:Contacts"
      "calendar:calendar:Calendar"
      "photos:photos:Photos"
      "drive:iclouddrive:Drive"
      "notes:notes:Notes"
      "reminders:reminders:Reminders"
      "pages:pages:Pages"
      "numbers:numbers:Numbers"
      "keynote:keynote:Keynote"
      "find:find:Find"
    )

    install -d "$out/share/icons/hicolor/512x512/apps"
    install -d "$out/share/applications"

    for entry in "''${apps[@]}"; do
      cmd="''${entry%%:*}"
      rest="''${entry#*:}"
      path="''${rest%%:*}"
      title="''${rest#*:}"
      iconPattern='Icon=${"$"}{SNAP}/meta/gui/'"''${cmd}"'.png'

      makeWrapper "$out/bin/icloud-for-linux" "$out/bin/icloud-''${cmd}" \
        --add-flags "''${path}" \
        --add-flags "''${title}"

      install -Dm644 ${src}/snap/gui/"''${cmd}".png \
        "$out/share/icons/hicolor/512x512/apps/icloud-''${cmd}.png"

      install -Dm644 ${src}/snap/gui/"''${cmd}".desktop \
        "$out/share/applications/icloud-''${cmd}.desktop"

      substituteInPlace "$out/share/applications/icloud-''${cmd}.desktop" \
        --replace-fail "Exec=icloud-for-linux.''${cmd}" "Exec=icloud-''${cmd}" \
        --replace-fail "''${iconPattern}" "Icon=icloud-''${cmd}" \
        --replace-fail "StartupWMClass=icloud-for-linux.''${cmd}" "StartupWMClass=icloud-''${cmd}" \
        --replace-fail "Version=0.11" "Version=${version}"
    done

    runHook postInstall
  '';

  meta = {
    description = "Unofficial WebKitGTK wrappers for iCloud web apps";
    homepage = "https://github.com/cross-platform/icloud-for-linux";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "icloud-mail";
  };
}
