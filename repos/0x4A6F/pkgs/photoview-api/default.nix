{ lib
, fetchFromGitHub
, buildGoModule
, blas
, dlib
, lapack
, libjpeg
, darktable
, ffmpeg
}:

buildGoModule rec {
  pname = "photoview-api";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "photoview";
    repo = "photoview";
    rev = "v${version}";
    sha256 = "0ggwws02xi0b0jbczphc3x4qjl9h6rp27hbh5rlnmzygjbhnlwg9";
  };
  vendorSha256 = "1ifs2lwc8inkagbgc5nlhd5rzm64w9m0q088kqmjiky4kr06b6ma";

  modRoot = "./api";

  buildInputs = [
    blas
    dlib
    lapack
    libjpeg
  ];
  propagetedBuildInputs = [
    darktable
    ffmpeg
  ];

  meta = with lib; {
    description = "Photo gallery for self-hosted personal servers";
    homepage = "https://photoview.github.io/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ _0x4A6F ];
  };
}
