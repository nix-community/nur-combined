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
  version = "unstable-2021-05-27";

  src = fetchFromGitHub {
    owner = "clementgallet";
    repo = "libTAS";
    rev = "1eb4ecc5462248bfd6846ea2f701453d575a9b78";
    hash = "sha256:12b0li168z2psw6s754lbysiwj6gjfjxq9pcpx64yxfrzarnxw2w";
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
    ./typo-in-typo.patch
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
