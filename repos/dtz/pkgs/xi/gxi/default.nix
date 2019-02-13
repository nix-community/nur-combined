{ stdenv, fetchFromGitHub, rustPlatform, cmake, pkgconfig, freetype, gtk3, wrapGAppsHook, xi-core }:

rustPlatform.buildRustPackage rec {
  name = "gxi-unstable-${version}";
  version = "2019-02-11";
  
  src = fetchFromGitHub {
    owner = "Cogitri";
    repo = "gxi";
    rev = "f9af4f66b64098e94a87f1b29b2665d5d59a9c34";
    sha256 = "0a956clrvyfk54qn4l3ck75vgvzqkldg331n3iy5a6dkf62jv49c";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkgconfig freetype ];

  buildInputs = [
    gtk3
    wrapGAppsHook
  ];

  GXI_PLUGIN_DIR = "${placeholder "out"}/share/xi/plugins";

  hardeningDisable = [ "format" ]; # build error in gettext/gnulib??

  cargoSha256 = "1wn8jymxkg8a14lmak5l1agjizvym9vpbb9smhgz4mv89gppf4il";

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
