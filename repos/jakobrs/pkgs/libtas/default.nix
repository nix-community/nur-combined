{
  # Things which aren't really dependencies
  stdenv, multiStdenv, lib, fetchFromGitHub, fetchpatch,

  # build-time dependencies
  wrapQtAppsHook,
  autoreconfHook, pkgconfig,
  git, # Used in configure to generate a version string or something like that

  # runtime dependencies
  xcbutilcursor, SDL2, alsaLib, ffmpeg,

  # Even more runtime dependencies
  file, # Used to get information about the architecture of a file

  # Multiarch is enabled whenever possible
  multiArch ? stdenv.hostPlatform.isx86_64, pkgsi686Linux
}:

let
  relevantStdenv = if multiArch then multiStdenv else stdenv;

in relevantStdenv.mkDerivation rec {
  pname = "libtas";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "clementgallet";
    repo = "libTAS";
    rev = "v${version}";
    hash = "sha256:17apyhaivc74nlsaq84q48l6by1njjk6c24x0j012lcjjzvq3nca";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig wrapQtAppsHook git ];
  buildInputs = [
    xcbutilcursor SDL2 alsaLib ffmpeg
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
    ./libtaspath.patch
    (fetchpatch {
      url = "https://github.com/clementgallet/libTAS/commit/f12b1080c177e3281419c6e1c8e45dbd7b3544fb.patch";
      sha256 = "121qqvb77zxrmbkzfcbfh7jzjsr116nsnip0l4vk5v1bqmng0xkk";
    })
  ];

  # Note that this builds an extra .so file in the same derivation
  # Ideally the library and executable might be split into separate derivations,
  # but this is easier for now
  configureFlags = [
    "--disable-build-date"
  ] ++ lib.optional multiArch "--with-i386";

  postPatch = ''
    substituteInPlace src/program/main.cpp \
      --subst-var out
  '';

  postInstall = ''
    mkdir -p $out/lib
    mv $out/bin/libtas*.so $out/lib/
  '';

  enableParallelBuilding = true;

  postFixup = ''
    wrapProgram $out/bin/libTAS --suffix PATH : ${lib.makeBinPath [ file ]}
  '';

  meta = {
    platforms = [ "x86_64-linux" "i686-linux" ];
    description = "GNU/Linux software to (hopefully) give TAS tools to native games";
    license = lib.licenses.gpl3Only;
  };
}
