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
  # Chromium uses this as the Wayland app_id for --app with the default profile.
  xdgAppId = "chrome-www.crunchyroll.com__-Default";
  url = "https://www.crunchyroll.com/";
  chromiumWidevine = chromium.override {
    enableWideVine = true;
  };

  launchArgs = [
    "--app=${url}"
    "--class=${xdgAppId}"
    "--no-first-run"
    "--no-default-browser-check"
  ]
  ++ lib.optionals disableGpu [ "--disable-gpu" ]
  ++ extraLaunchArgs;
in
makeDesktopItem {
  name = xdgAppId;

  desktopName = "Crunchyroll";
  comment = "Stream anime on Crunchyroll";

  icon = fetchurl {
    url = "https://www.crunchyroll.com/build/assets/img/favicons/apple-touch-icon-v2-114x114.png";
    hash = "sha256-oVUyQEu4giQybuFHgFN0BkolUIfuWMKvWvL1Rv9Ayi8=";
  };

  categories = [
    "Network"
    "AudioVideo"
  ];

  # Keep X11 WM_CLASS and the Wayland app_id aligned with the desktop entry.
  startupWMClass = xdgAppId;
  exec = writeShellScript name ''
    exec ${chromiumWidevine}/bin/chromium \
      ${lib.escapeShellArgs launchArgs}
  '';

  terminal = false;

  extraConfig = {
    "Comment[es]" = "Ver anime en Crunchyroll";
  };
}
