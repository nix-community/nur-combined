{ stdenv, fetchFromGitHub, rustPlatform, cmake, pkgconfig, freetype, gtk3, wrapGAppsHook, xi-core }:

rustPlatform.buildRustPackage rec {
  name = "gxi-unstable-${version}";
  version = "2019-02-01";
  
  src = fetchFromGitHub {
    owner = "Cogitri";
    repo = "gxi";
    rev = "8c4cb673417f391d6ddc2b868ded2c5569ab0cd9";
    sha256 = "1p9w2hhanqnzh73iim3s9sd0g8f5dvzfjy8wycxiygsfcaajv1ha";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkgconfig freetype ];

  buildInputs = [
    gtk3
    wrapGAppsHook
  ];

  GXI_PLUGIN_DIR = "${placeholder "out"}/share/xi/plugins";

  hardeningDisable = [ "format" ]; # build error in gettext/gnulib??

  cargoSha256 = "1ani8xm55mgrrf5m2va26m5c75qrql9k4l5i05rhrbvn9y37c881";

  postInstall = ''
    mkdir -p ${GXI_PLUGIN_DIR}
    ln -s ${xi-core.syntect} ${GXI_PLUGIN_DIR}/synctect
  '';

  meta = with stdenv.lib; {
    description = "GTK frontend for the xi text editor, written in rust";
    homepage = https://github.com/bvinc/gxi;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
