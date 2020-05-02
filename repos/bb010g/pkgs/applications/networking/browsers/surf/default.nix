{ stdenv, fetchgit
, pkgconfig, wrapGAppsHook
, gcr, glib, glib-networking, gsettings-desktop-schemas, gtk, libsoup
, webkitgtk
, coreutils, dmenu, findutils, gnused, xorg
, patches ? null
}:

let
  inherit (stdenv) lib;
in
stdenv.mkDerivation {
  pname = "surf-unstable";
  version = "2019-02-08";

  src = fetchgit {
    url = "https://git.suckless.org/surf";
    # rev = "master";
    rev = "d068a3878b6b9f2841a49cd7948cdf9d62b55585";
    sha256 = "0pjsv2q8c74sdmqsalym8wa2lv55lj4pd36miam5wd12769xw68m";
  };

  nativeBuildInputs = [
    pkgconfig
    wrapGAppsHook
  ];
  buildInputs = [
    (lib.getDev gcr)
    glib
    glib-networking
    gsettings-desktop-schemas
    gtk
    libsoup
    webkitgtk
  ];

  patches = let defaultPatches = [
    ./update-uri.patch
  ]; in if patches == null then defaultPatches
    else if lib.isFunction patches then patches defaultPatches
    else defaultPatches ++ patches;

  installFlags = [ "PREFIX=$(out)" ];

  # Add run-time dependencies to PATH. Append them to PATH so the user can
  # override the dependencies with their own PATH.
  preFixup = let
    depsPath = lib.makeBinPath [
      coreutils
      dmenu
      findutils
      gnused
      xorg.xprop
    ];
  in ''
    gappsWrapperArgs+=(
      --suffix PATH : ${depsPath}
    )
  '';

  meta = with lib; {
    description = "A simple web browser based on WebKit/GTK";
    longDescription = ''
      Surf is a simple web browser based on WebKit/GTK. It is able to display
      websites and follow links. It supports the XEmbed protocol which makes it
      possible to embed it in another application. Furthermore, one can point
      surf to another URI by setting its XProperties.
    '';
    homepage = "https://surf.suckless.org/";
    license = licenses.mit;
    platforms = webkitgtk.meta.platforms;
    maintainers = with maintainers; [ bb010g joachifm ];
  };
}
