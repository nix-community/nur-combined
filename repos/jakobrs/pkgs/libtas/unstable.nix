{
  # Things which aren't really dependencies
  stdenv, multiStdenv, lib, fetchFromGitHub, fetchpatch,

  # build-time dependencies
  wrapQtAppsHook,
  autoreconfHook, pkgconfig,
  git, # Used in configure to generate a version string or something like that

  # runtime dependencies
  xcbutilcursor, SDL2, alsaLib, ffmpeg, lua5_3,

  # Even more runtime dependencies
  file, # Used to get information about the architecture of a file

  # Multiarch is enabled whenever possible
  multiArch ? stdenv.hostPlatform.isx86_64, pkgsi686Linux
}:

let
  relevantStdenv = if multiArch then multiStdenv else stdenv;

in relevantStdenv.mkDerivation rec {
  pname = "libtas";
  version = "unstable-2021-05-15";

  src = fetchFromGitHub {
    owner = "clementgallet";
    repo = "libTAS";
    rev = "652c8d3da34ec83b4e7e2ec91da9cdaaf1d48501";
    hash = "sha256:0jk1h2hbv2cy8szrc8x0wnzc4kwdmd83irqwz1gc3hqn1y0wz4sc";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig wrapQtAppsHook git ];
  buildInputs = [
    xcbutilcursor SDL2 alsaLib ffmpeg lua5_3
  ] ++ lib.optionals multiArch [
    pkgsi686Linux.xorg.xcbutilcursor
    pkgsi686Linux.SDL2
    pkgsi686Linux.alsaLib
    pkgsi686Linux.ffmpeg
    pkgsi686Linux.fontconfig
    pkgsi686Linux.freetype
  ];

  dontStrip = true; # Segfaults, bug in patchelf

  patches = [
    (fetchpatch {
      url = "https://github.com/clementgallet/libTAS/pull/415.patch";
      sha256 = "1kbpink7laa7vx2r1izlq0wgn512bbq7pgv410556phc84q9dl90";
    })
  ];

  # Note that this builds an extra .so file in the same derivation
  # Ideally the library and executable might be split into separate derivations,
  # but this is easier for now
  configureFlags = [
    "--disable-build-date"
  ] ++ lib.optional multiArch "--with-i386";

  postInstall = ''
    mkdir -p $out/lib
    mv $out/bin/libtas*.so $out/lib/
  '';

  enableParallelBuilding = true;

  postFixup = ''
    wrapProgram $out/bin/libTAS \
      --suffix PATH : ${lib.makeBinPath [ file ]} \
      --set-default LIBTAS_SO_PATH $out/lib/libtas.so
  '';

  meta = {
    platforms = [ "x86_64-linux" "i686-linux" ];
    description = "GNU/Linux software to (hopefully) give TAS tools to native games";
    license = lib.licenses.gpl3Only;
  };
}
