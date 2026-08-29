# N.B.: epiphany requires this to be installed, and with the .desktop entry linked into ~/.local/share/xdg-desktop-portal/applications,
#   otherwise clicking *any* link will crash it.
# N.B. the `Exec=` link in the .desktop file include the base url.
#   This is how epiphany knows to _not_ direct links within the site to the system handler.
{
  copyDesktopItems,
  epiphany,
  lib,
  makeDesktopItem,
  static-nix-shell,
}:
{
  appName,  # e.g. "Kagi"
  baseUrl,  # e.g. "https://kagi.com/
  appId ? "org.gnome.Epiphany.WebApp_${appName}",
  # .desktop fields:
  comment ? appName,  # e.g. "Search with Kagi"
  desktopName ? appName,  # e.g. "Search Engine"
  ...
}@attrs:
let
  extraAttrs = lib.removeAttrs attrs [
    "appId"
    "appName"
    "baseUrl"
    "comment"
    "desktopName"
  ];
in
# TODO: this doesn't really benefit from using static-nix-shell: port to something simpler/faster
static-nix-shell.mkBash (finalAttrs: {
  pname = appId;
  src = ./src;
  pkgs = {
    "epiphany" = finalAttrs.passthru.epiphany;
  };

  nativeBuildInputs = [
    copyDesktopItems
  ];
  desktopItems = [
    (makeDesktopItem {
      inherit comment desktopName;
      name = appId;  # must match --profile option
      exec = "${appId} ${baseUrl} %U";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" "GNOME" "GTK" ];
      startupNotify = true;
      startupWMClass = appId;
      icon = "web-browser";
    })
  ];

  postPatch = ''
    cp launcher ${finalAttrs.passthru.appId}
    substituteInPlace ${finalAttrs.passthru.appId} \
      --replace-fail '@appId@' '${finalAttrs.passthru.appId}' \
      --replace-fail '@baseUrl@' '${baseUrl}' \
      --replace-fail '@epiphany@' '${lib.getExe finalAttrs.passthru.epiphany}' \
  '';

  doInstallCheck = false;  # would need xvfb
  # preInstallCheck = ''
  #   export HOME=$(mktemp -d)
  # '';

  passthru = {
    inherit appId;
    epiphany = epiphany.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        # 2026-06-25: when an Epiphany webapp is invoked a second time with a URL,
        # it normally just presents the existing window and discards the URL.
        # allow the remote instance to pass its URL through to the running app.
        ./epiphany-appmode-remote-url.patch
      ];
      postPatch = (upstream.postPatch or "") + ''
        # pretend we're running under Flatpak so that we *always* dispatch non-webapp URIs through the portal.
        # XXX(2026-08-28): function name changes to `xdp_portal_running_under_sandbox` in future versions
        substituteInPlace lib/ephy-file-helpers.c --replace-fail \
          'ephy_is_running_inside_sandbox ()' \
          'true'
      '';
      postInstall = (upstream.postInstall or "") + ''
        mv $out/bin/epiphany $out/bin/_${appId}-epiphany
      '';
      meta = (upstream.meta or {}) // {
        mainProgram = "_${appId}-epiphany";
      };
    });
  };
} // extraAttrs)
