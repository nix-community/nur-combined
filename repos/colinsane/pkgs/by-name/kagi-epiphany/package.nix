# N.B.: epiphany requires this to be installed, and with the .desktop entry linked into ~/.local/share/xdg-desktop-portal/applications,
#   otherwise clicking *any* link will crash it.
# N.B. the `Exec=` link in the .desktop file MUST end with `https://kagi.com/`. This is epiphany knows to _not_ direct kagi.com links to the system handler.
{
  epiphany,
  lib,
  makeWrapper,
  stdenvNoCC,
}:
let
  appName = "Kagi";
  # Epiphany defaults to WebApp_${sha1("Kagi")}, but only the WebApp_ prefix is required -- sha1 is optional
  # appId = "org.gnome.Epiphany.WebApp_${appName}";
  appId = "org.gnome.Epiphany.WebApp_424cfc679f24e45b65660e152e6ba961a21645ce";
in
stdenvNoCC.mkDerivation {
  pname = "kagi-epiphany";
  version = "1.0";

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications
    cp ${lib.getExe epiphany} $out/bin/kagi-epiphany

    # TODO: if invoked with no arguments, then append 'https://kagi.com/' to have that be the default landing page.
    wrapProgram $out/bin/kagi-epiphany \
      --run 'mkdir -p ''${XDG_DATA_HOME:-$HOME/.local/share}/${appId} && touch ''${XDG_DATA_HOME:-$HOME/.local/share}/${appId}/.app' \
      --append-flags '--application-mode --profile ''${XDG_DATA_HOME:-$HOME/.local/share}/${appId}'

    cat > $out/share/applications/${appId}.desktop <<EOF
    [Desktop Entry]
    Name=${appName}
    GenericName=Search Engine
    Comment=Search with Kagi
    Exec=kagi-epiphany https://kagi.com/
    Terminal=false
    Type=Application
    Categories=Network;WebBrowser;GNOME;GTK;
    StartupNotify=true
    StartupWMClass=${appId}
    Icon=web-browser
    X-Purism-FormFactor=Workstation;Mobile;
    EOF

    runHook postInstall
  '';

  meta = {
    description = "Kagi web app launcher using GNOME Web / Epiphany";
    mainProgram = "kagi-epiphany";
  };
}
