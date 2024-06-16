{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  xorg,
  libglvnd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qoiview";
  version = "0-unstable-2024-05-10";

  src = fetchFromGitHub {
    owner = "floooh";
    repo = "qoiview";
    rev = "7a371020708b71d414c85977ea233d721f91d937";
    hash = "sha256-V4NdhTzTGd62pNkKhk1vo1vZa/z24r+zKbojI0ziG/E=";
  };

  nativeBuildInputs = [ cmake ];

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isLinux (
    with xorg;
    [
      "-I${libX11.dev}/include"
      "-I${xorgproto}/include"
      "-I${libXi.dev}/include"
      "-I${libXext.dev}/include"
      "-I${libXfixes.dev}/include"
      "-I${libXcursor.dev}/include"
      "-I${libglvnd.dev}/include"
    ]
  );

  NIX_LDFLAGS = lib.optionals stdenv.isLinux (
    with xorg;
    [
      "-L${libX11}/lib"
      "-L${libXi}/lib"
      "-L${libXcursor}/lib"
      "-L${libglvnd}/lib"
    ]
  );

  installPhase = ''
    install -Dm755 qoiview -t $out/bin
  '';

  meta = {
    description = "QOI image viewer on top of the Sokol headers";
    homepage = "https://github.com/floooh/qoiview";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
