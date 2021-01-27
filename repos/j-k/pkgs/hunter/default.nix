{ stdenv
, rustPlatform
, fetchgit
, IOKit ? null
, makeWrapper
, pkg-config
, glib
, gst_all_1
, libsixel
}:

assert stdenv.isDarwin -> IOKit != null;
rustPlatform.buildRustPackage rec {
  pname = "hunter";
  version = "stable-2021-01-27";

  src = fetchgit {
    url = "https://github.com/06kellyjac/${pname}.git";
    rev = "2484f0db580bed1972fd5000e1e949a4082d2f01";
    sha256 = "sha256-oSuwM6cxEw4ybiwoYX6A/aqiU6NVu9cLLONalUHuE1A=";
  };

  cargoSha256 = "sha256-pWQl5d+6aFGP9lq7FAjXZ/2R6B29D4urKkktmg4Wypo=";

  nativeBuildInputs = [ makeWrapper pkg-config ];
  buildInputs = [
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-bad
    libsixel
  ] ++ stdenv.lib.optionals stdenv.isDarwin [ IOKit ];

  # doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/hunter --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"
  '';

  meta = with stdenv.lib; {
    description = "The fastest file manager in the galaxy - rust stable fork";
    homepage = "https://github.com/06kellyjac/hunter/tree/hunter_rust_stable_updated";
    license = licenses.wtfpl;
    maintainers = with maintainers; [ jk ];
    platforms = platforms.unix;
  };
}
