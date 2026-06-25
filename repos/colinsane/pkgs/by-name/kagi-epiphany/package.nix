# N.B.: epiphany requires this to be installed, and with the .desktop entry linked into ~/.local/share/xdg-desktop-portal/applications,
#   otherwise clicking *any* link will crash it.
# N.B. the `Exec=` link in the .desktop file MUST end with `https://kagi.com/`. This is epiphany knows to _not_ direct kagi.com links to the system handler.
{
  copyDesktopItems,
  makeDesktopItem,
  epiphany,
  static-nix-shell,
}:
let
  appName = "Kagi";
  # Epiphany defaults to WebApp_${sha1("Kagi")}, but only the WebApp_ prefix is required -- sha1 is optional
  appId = "org.gnome.Epiphany.WebApp_${appName}";
  # N.B.: KEEP IN SYNC WITH ./kagi-epiphany
  # appId = "org.gnome.Epiphany.WebApp_424cfc679f24e45b65660e152e6ba961a21645ce";
in
static-nix-shell.mkBash rec {
  pname = "kagi-epiphany";
  srcRoot = ./.;
  pkgs = {
    "kagi-epiphany.epiphany" = passthru.epiphany;
  };

  nativeBuildInputs = [
    copyDesktopItems
  ];
  desktopItems = [
    (makeDesktopItem {
      name = appId;  # must match --profile option
      desktopName = "Search Engine";
      comment = "Search with Kagi";
      exec = "kagi-epiphany https://kagi.com/ %U";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" "GNOME" "GTK" ];
      startupNotify = true;
      startupWMClass = appId;
      icon = "web-browser";
    })
  ];

  doInstallCheck = false;  # would need xvfb
  # preInstallCheck = ''
  #   export HOME=$(mktemp -d)
  # '';

  passthru = {
    inherit appId;
    epiphany = epiphany.overrideAttrs (upstream: {
      # 2026-06-25: when an Epiphany webapp is invoked a second time with a URL,
      # it normally just presents the existing window and discards the URL.
      # allow the remote instance to pass its URL through to the running app.
      patches = (upstream.patches or []) ++ [ ./epiphany-appmode-remote-url.patch ];
      postInstall = (upstream.postInstall or "") + ''
        mv $out/bin/epiphany $out/bin/_kagi-epiphany
      '';
    });
  };

  meta = {
    description = "Kagi web app launcher using GNOME Web / Epiphany";
    mainProgram = "kagi-epiphany";
  };
}
