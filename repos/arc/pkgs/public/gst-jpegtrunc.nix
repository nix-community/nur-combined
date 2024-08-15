{ fetchFromGitHub, rustPlatform, hostPlatform, pkg-config, gstreamer ? gst_all_1.gstreamer, gst_all_1 ? null }: rustPlatform.buildRustPackage rec {
  pname = "gst-jpegtrunc";
  version = "2021-06-14";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = pname;
    rev = "6abf1997d6eabd0958e74303407d6a9543cc1977";
    sha256 = "0xk36nbzahn5w5a1y2lwdmbg90s8ja6nq9a0ry5w08344lm2l47s";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gstreamer ];

  cargoHash = "sha256-96VOWzBReeV08OjQd4LGEIXAnuJwxQk84RRc6aPqLxo=";

  libname = "libgstjpegtrunc" + hostPlatform.extensions.sharedLibrary;
  postInstall = ''
    mkdir -p $out/lib/gstreamer-1.0
    mv $out/lib/$libname $out/lib/gstreamer-1.0/
  '';
}
