{ stdenv, fetchFromGitHub, glib, gtk3, gzip, pkgconfig, wrapGAppsHook }:

stdenv.mkDerivation rec {
  pname = "iwgtk";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "J-Lentz";
    repo = pname;
    rev = "v${version}";
    sha256 = "129h7vq9b1r9a5c79hk8d06bj8lgzrnhq55x54hqri9c471jjh0s";
  };

  nativeBuildInputs = [ glib gzip pkgconfig wrapGAppsHook ];
  buildInputs = [ gtk3 ];

  makeFlags = [ "prefix=$(out)" ];

  postInstall = ''
    substituteInPlace "$out/share/applications/iwgtk.desktop" --replace "Exec=iwgtk" "Exec=$out/bin/iwgtk"
  '';

  meta = with stdenv.lib; {
    description = " Lightweight, graphical wifi management utility for Linux";
    longDescription = ''
      iwgtk is a lightweight, graphical wifi management utility for Linux.
      It is used to control iwd, with supported functionality similar to that of iwctl.
      It is particularly useful in a system where iwd is being used as a standalone network management daemon (i.e., without NetworkManager).
    '';
    homepage = "https://github.com/J-Lentz/iwgtk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.gnu;
  };
}
