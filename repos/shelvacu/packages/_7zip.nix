{ stdenv, fetchurl }:
stdenv.mkDerivation (finalAttrs: {
  pname = "7zip";
  version = "26.01";

  src = fetchurl {
    url = "https://sourceforge.net/projects/sevenzip/files/7-Zip/${finalAttrs.version}/7z${
      builtins.replaceStrings [ "." ] [ "" ] finalAttrs.version
    }-src.tar.xz";
    hash = "sha256-sjieDpMLL5o0jPD+fZhwpGSCqOwETuC99C4hNtsxw9Y=";
  };

  sourceRoot = ".";

  postPatch = "cd CPP/7zip/Bundles/Alone2";

  makefile = "makefile.gcc";

  installPhase = ''
    ls -al _o
    install -D _o/7zz "$out"/bin/7zz
  '';

  meta.mainProgram = "7zz";
})
