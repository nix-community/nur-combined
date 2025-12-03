{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  qt6,
  libusb1,
  pkg-config,

  # either `systemd` or `eudev` can provide libudev.
  systemd ? null,
  eudev ? null,
  useSystemd ? null,
  libudev ? null,
}@args:
stdenv.mkDerivation (
  finalAttrs:
  let
    args_libudev = args.libudev or null;
    inherit (finalAttrs.finalPackage) useSystemd;
    libudev =
      # if something called libudev was passed explicitly, use that
      if args_libudev != null then
        args_libudev
      # if useSystemd is (non-null and) true, then use systemd
      else if useSystemd == true then
        systemd
      # if useSystemd is (non-null and) false, then use eudev
      else if useSystemd == false then
        eudev
      # if useSystemd is not null, true, or false, that's invalid
      else if useSystemd != null then
        builtins.throw "useSystemd must be true, false, or null"
      # at this point useSystemd is null. Default to systemd iff there is a systemd package
      else if systemd != null then
        systemd
      # otherwise try to use eudev
      else
        eudev;
  in
  {
    pname = "openterface-qt";
    version = "0.3.19";

    src = fetchFromGitHub {
      owner = "TechxArtisanStudio";
      repo = "Openterface_QT";
      rev = finalAttrs.version;
      hash = "sha256-R6mz5oKnLp0bIhOLRQJnh5L5hkZkJZXLtCWCzcIxsNY=";
    };

    nativeBuildInputs = [
      qt6.wrapQtAppsHook
      qt6.qmake
      pkg-config
    ];

    buildInputs =
      (with qt6; [
        qtbase
        qtmultimedia
        qtserialport
        qtsvg
      ])
      ++ [
        libusb1
        libudev
      ];

    preInstall = ''
      mkdir -p "$out"/bin
      cp ./openterfaceQT "$out"/bin/openterface-qt
    '';

    passthru = {
      useSystemd = args.useSystemd or null;
      inherit libudev;
      updateScript = nix-update-script { };
      withoutSystemd = finalAttrs.finalPackage.overrideAttrs (old: {
        passthru = old.passthru // {
          useSystemd = false;
        };
      });
      withSystemd = finalAttrs.finalPackage.overrideAttrs (old: {
        passthru = old.passthru // {
          useSystemd = true;
        };
      });
    };

    meta = {
      description = "Client software for Openterface Mini-KVM";
      homepage = "https://openterface.com/app/qt/";
      changelog = "https://github.com/TechxArtisanStudio/Openterface_QT/releases";
      license = [ lib.licenses.agpl3Only ];
      sourceProvenance = [ lib.sourceTypes.fromSource ];
      mainProgram = "openterface-qt";
      platforms = lib.platforms.all;
    };
  }
)
