{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, gnome3, gtk-engine-murrine }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "solarc-theme";
  version = "v1.0.2";

  src = fetchFromGitHub {
    owner = "schemar";
    repo = pname;
    rev = version;
    sha256 = "0kh6hb8id6rfsd7hda9j3l6ssivs01sfqgds03m3z842vclapdk5";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  buildInputs = [ gtk-engine-murrine ];

  preferLocalBuild = true;

  gtkVersion = stdenv.lib.versions.majorMinor gnome3.gnome-desktop.version;

  configureFlags = [ "--disable-unity" "--with-gnome=${gtkVersion}" ];

  preConfigure = ''
    ln -vs 3.20 common/gtk-3.0/${gtkVersion}
    ln -vs 3.20 common/gnome-shell/${gtkVersion}
  '';

  postInstall = ''
    mkdir -p $out/share/plank/themes
    cp -r extra/*-Plank $out/share/plank/themes
    mkdir -p $out/share/doc/$pname/Chrome
    cp -r extra/Chrome/*.crx $out/share/doc/$pname/Chrome
    cp AUTHORS README.md $out/share/doc/$pname/
  '';

  meta = with stdenv.lib; {
    description = "A solarized flat theme with transparent elements";
    homepage = https://github.com/schemar/solarc-theme;
    license = licenses.gpl3;
  };
}
