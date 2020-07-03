{ cmake, fetchFromGitHub, ffmpeg_4, fltk, lib, libGL, libGLU, libX11
, libXcomposite, libXcursor, libXext, libXfixes, libXft, libXinerama, libXrandr
, libXtst, nodePackages, openssl, pkg-config, rustPlatform, stdenv, x264 }:

let

  version = "0.7.2";

in rustPlatform.buildRustPackage {
  pname = "weylus";
  inherit version;

  src = fetchFromGitHub {
    owner = "H-M-H";
    repo = "Weylus";
    rev = "v${version}";
    sha256 = "03nd90h6ba9g6gpdvnznp3mlq6ml1f5rzdzyzv8bj2rvvgl0cs5n";
  };

  cargoSha256 = "1sjba7nv7kws03lp106vamqpz3gn95bq112gpv95rgsj5cajgapp";
  verifyCargoDeps = true;

  nativeBuildInputs = [ nodePackages.typescript pkg-config ];

  buildInputs = [
    cmake
    ffmpeg_4
    fltk
    libGL
    libGLU
    libX11
    libXcomposite
    libXcursor
    libXext
    libXfixes
    libXft
    libXinerama
    libXrandr
    libXtst
    openssl
    x264
  ];

  prePatch = ''
    mkdir -p deps/dist/{include,lib}

    substituteInPlace build.rs \
      --replace rustc-link-lib=static= rustc-link-lib=
  '';

  meta = with stdenv.lib; {
    description =
      "Use your tablet as graphic tablet/touch screen on your computer";
    homepage = "https://github.com/H-M-H/Weylus";
    license = licenses.agpl3;
    maintainers = [ maintainers.rycee ];
    platforms = platforms.unix;
  };
}
