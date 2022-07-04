{
  stdenv,
  fetchgit,
  lib,
  wrapGAppsHook,
  pkg-config,
  perl534Packages,
  webkitgtk,
  libxml2,
  gettext,
  glib-networking,
}:
stdenv.mkDerivation rec {
  pname = "badwolf";
  version = "+g6e9679c.develop";

  src = fetchgit {
    url = "https://hacktivis.me/git/badwolf.git";
    sha256 = "10z7ccffs3737lwmq8clybppgwvj01qncl0lhgibjklx1zfyiqpx";
    rev = "6e9679c1f6fe3b64ebbeb4a94dcc0060b3e6356d";
  };

  nativeBuildInputs = [
    wrapGAppsHook
    glib-networking
    pkg-config
    perl534Packages.Po4a
  ];

  buildInputs = [
    webkitgtk
    libxml2
    gettext
  ];

  doCheck = false;

  configurePhase = "./configure PREFIX=$out";

  meta = with lib; {
    description = "Minimalist privacy-oriented web browser.";
    longDescription = ''
      A minimalist and privacy-oriented web browser based on WebKitGTK.
      Created by Lanodan at hacktivis.me.
    '';
    homepage = "https://hacktivis.me/git/badwolf/file/README.md.html";
    changelog = "https://hacktivis.me/git/badwolf/log.html";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
