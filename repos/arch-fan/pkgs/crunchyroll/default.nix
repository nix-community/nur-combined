{
  chromium,
  fetchurl,
  lib,
  makeDesktopItem,
  writeShellScript,

  disableGpu ? true,
  extraLaunchArgs ? [ ],
}:

let
  name = "crunchyroll";
  url = "https://www.crunchyroll.com/";

  chromiumWidevine = chromium.override {
    enableWideVine = true;
  };

  launchArgs = [
    "--app=${url}"
    "--no-first-run"
    "--no-default-browser-check"
  ]
  ++ lib.optionals disableGpu [
    "--disable-gpu"
  ]
  ++ extraLaunchArgs;
in

makeDesktopItem {
  inherit name;

  desktopName = "Crunchyroll";

  icon = fetchurl {
    url = "https://www.crunchyroll.com/build/assets/img/favicons/apple-touch-icon-v2-114x114.png";
    hash = lib.fakeHash;
  };

  categories = [
    "Network"
    "AudioVideo"
  ];

  exec = writeShellScript name ''
    exec ${chromiumWidevine}/bin/chromium \
      ${lib.escapeShellArgs launchArgs}
  '';

  terminal = false;
}
