{ stdenv
, fetchFromGitHub
, gstreamer ? gst_all_1.gstreamer
, gst-rtsp-server ? gst_all_1.gst-rtsp-server
, gst-plugins-base ? gst_all_1.gst-plugins-base
, gst_all_1 ? null
, cmake
}: stdenv.mkDerivation rec {
  pname = "gst-rtsp-launch";
  version = "2019-12-26";

  src = fetchFromGitHub {
    owner = "sfalexrog";
    repo = "gst-rtsp-launch";
    rev = "f466b3f4d3b62d847344ae0aa86531c4aec266bb";
    sha256 = "07x5fkryq2r98gbhfsg14zfgb0ypplvcsjy18hsznk7q0hc96gba";
  };

  patches = [ ./cmake.patch ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ gstreamer gst-plugins-base gst-rtsp-server ];
}
