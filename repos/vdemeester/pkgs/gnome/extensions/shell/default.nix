{ stdenv, fetchFromGitHub, glib, gettext, bash, nodePackages, gnome3 }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-shell-unstable";
  version = "2020-03-13";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    rev = "9e8ab29cb976b078aa6e8fab59b09527a092a1b8";
    sha256 = "1za5jj95p095z4ffjli0ir3prd8fiv2bdjgjmb7h6wnni65cwfa3";
  };

  nativeBuildInputs = [
    glib
    gettext
    nodePackages.typescript
  ];

  uuid = "pop-shell@system76.com";

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions
    cp -r _build $out/share/gnome-shell/extensions/${uuid}
  '';

  meta = with stdenv.lib; {
    description = "Pop Shell is a keyboard-driven layer for GNOME Shell which allows for quick and sensible navigation and management of windows.";
    license = licenses.gpl3;
    maintainers = with maintainers; [ vdemeester ];
    homepage = "https://github.com/pop-os/shell";
  };
}
