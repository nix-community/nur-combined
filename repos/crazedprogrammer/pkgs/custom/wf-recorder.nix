{ stdenv, fetchFromGitHub, meson, ninja, wayland, wayland-protocols, ffmpeg, pkg-config, x264 }:

stdenv.mkDerivation rec {
  name = "wf-recorder-${version}";
  version = "2019-03-13";

  src = fetchFromGitHub {
    owner = "ammen99";
    repo = "wf-recorder";
    rev = "e6ea77a2569c04975cab8655f5ad4dbcf86df1f5";
    sha256 = "1jhj5syzy8i8f9b3j4g12jmc5fcsiv4df9hgribdvw61v5pfz9g1";
  };

  buildInputs = [ meson ninja wayland wayland-protocols ffmpeg pkg-config x264 ];
  enableParallelBuilding = true;
}
