{ stdenv, lib, fetchgit, makeWrapper, firefox, gnome }:

stdenv.mkDerivation rec {
  pname = "multifirefox";
  version = "unstable-2022-02-10";

  src = fetchgit {
    url = "https://codeberg.org/wolfangaukang/multifirefox.git";
    rev = "bfaeaabbf92bb45dc48111baa0ba70e74ba25975";
    sha256 = "sha256-XQxhMJSiXBqYB0mvdT6iSwcgrjJ6MK1pxMyBm+ZOGIw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ gnome.zenity ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    install -Dm 755 multifirefox -t $out/bin/
    install -Dm 644 multifirefox.desktop -t $out/share/applications/
    cp -R ${firefox}/share/icons $out/share/

    wrapProgram $out/bin/multifirefox \
      --prefix PATH ":" ${gnome.zenity}/bin
    substituteInPlace $out/share/applications/multifirefox.desktop \
      --replace "/usr/bin/env " "$out/bin/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Equivalent of `firefox -P PROFILE_NAME -no-remote` but with the remote enabled";
    homepage = "https://codeberg.org/wolfangaukang/multifirefox";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = platforms.linux;
  };
}
