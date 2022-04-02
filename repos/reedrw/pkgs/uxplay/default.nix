{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
, cmake
, pkg-config
, avahi-compat
, avahi
, elfutils
, gst_all_1
, libplist
, libselinux
, libsepol
, libunwind
, openssl
, orc
, pcre
, util-linuxMinimal
, zstd
}:

stdenv.mkDerivation rec {
  pname = "uxplay";
  version = "v1.48d";

  src = fetchFromGitHub {
    owner = "FDH2";
    repo = "UxPlay";
    rev = "v1.48d";
    sha256 = "sha256-vJzHltWdQ/nULm8DjLlbBfMUb1P6NTsUv4ZNgpwf4wg=";
  };

  gstBuildInputs = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gst-plugins-bad
    gst-libav
    gst-vaapi
    gst-devtools
  ];

  buildInputs = [
    makeWrapper
    avahi-compat
    avahi
    cmake
    libplist
    openssl
    pcre
    zstd
    orc
    libunwind
    libselinux
    libsepol
    elfutils
    util-linuxMinimal
  ] ++ gstBuildInputs;

  nativeBuildInputs = [
    pkg-config
  ];

  postInstall = ''
    wrapProgram "$out/bin/uxplay" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"
      #--set GST_PLUGIN_PATH "${lib.makeSearchPath "lib/gstreamer-1.0" gstBuildInputs}" \
  '';

  meta = with lib; {
    description = "AirPlay Unix mirroring server (package slightly broken only screen mirroring works)";
    homepage = "https://github.com/FDH2/UxPlay";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

}
