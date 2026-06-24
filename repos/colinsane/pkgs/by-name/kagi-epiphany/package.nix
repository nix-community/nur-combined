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
static-nix-shell.mkBash {
  pname = "kagi-epiphany";
  srcRoot = ./.;
  pkgs = {
    inherit epiphany;
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
  };

  meta = {
    description = "Kagi web app launcher using GNOME Web / Epiphany";
    mainProgram = "kagi-epiphany";
  };
}
