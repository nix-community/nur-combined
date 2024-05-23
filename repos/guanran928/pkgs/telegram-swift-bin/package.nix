{
  lib,
  fetchurl,
  makeWrapper,
  stdenv,
  undmg,
}:
stdenv.mkDerivation {
  pname = "telegram-swift-bin";
  version = "10.8.259860-stable";

  src = fetchurl {
    url = "https://web.archive.org/web/20240226150139/https://osx.telegram.org/updates/Telegram.dmg";
    hash = "sha256-hy7hnLP4fwhS46E9+tXgFRi9wO/GWlAFLi56S15Pcug=";
  };

  nativeBuildInputs = [makeWrapper undmg];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r "Telegram.app" $out/Applications

    mkdir -p $out/bin
    makeWrapper $out/Applications/Telegram.app/Contents/MacOS/Telegram $out/bin/telegram-swift

    runHook postInstall
  '';

  meta = {
    description = "Telegram is a cloud-based mobile and desktop messaging app with a focus on security and speed.";
    homepage = "https://telegram.org";
    license = lib.getLicenseFromSpdxId "GPL-2.0-only";
    platforms = lib.platforms.darwin;
  };
}
