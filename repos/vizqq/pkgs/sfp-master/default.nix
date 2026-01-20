{
  lib,
  stdenv,
  cmake,
  qt6,
  pkg-config,
  libusb1,
  wrapGAppsHook3,
  udev,
  source,
}:
stdenv.mkDerivation rec {
  inherit (source) pname src;

  version = lib.replaceStrings [ "v" ] [ "" ] source.version;

  buildInputs = [
    qt6.qtbase
    libusb1
    udev
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
    qt6.qttools
    wrapGAppsHook3
  ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "/usr/lib/udev" "$out/lib/udev"
  '';

  dontWrapGApps = true;
  strictDeps = true;
  doInstallCheck = true;

  meta = {
    description = "SFP-module programmer for CH341a devices";
    homepage = "https://github.com/bigbigmdm/SFP-Master";
    changelog = "https://github.com/bigbigmdm/SFP-Master/blob/${src.rev}/ChangeLog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "sfp-master";
    platforms = lib.platforms.linux;
  };
}
