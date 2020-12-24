{ stdenv
, rustPlatform
, fetchgit
, IOKit ? null
, makeWrapper
, glib
, gst_all_1
, libsixel
}:

assert stdenv.isDarwin -> IOKit != null;
rustPlatform.buildRustPackage rec {
  pname = "hunter";
  version = "2e95cc567c751263f8c318399f3c5bb01d36962a";

  src = fetchgit {
    url = "https://github.com/06kellyjac/${pname}.git";
    rev = "${version}";
    sha256 = "0wrp37hzd1hihc99dlr1dq8b0x6vymrxl4pr365l093psm4zdhwq";
  };

  cargoSha256 = "14hcbni7v8a87jxk4cdkyqwkhmp3zr4zflpbvsbgjax9adf5sl4v";

  # RUSTC_BOOTSTRAP = 1;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-bad
    libsixel
  ] ++ stdenv.lib.optionals stdenv.isDarwin [ IOKit ];

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/hunter --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"
  '';

  meta = with stdenv.lib; {
    description = "The fastest file manager in the galaxy - rust stable fork";
    homepage = "https://github.com/06kellyjac/hunter";
    license = licenses.wtfpl;
    maintainers = with maintainers; [ jk ];
    platforms = platforms.unix;
  };
}
