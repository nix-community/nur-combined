{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "7zip";
  version = "25.01";

  src = fetchurl {
    name = "7z2501-src.tar.xz";
    url = "https://sourceforge.net/projects/sevenzip/files/7-Zip/25.01/7z2501-src.tar.xz";
    hash = "sha256-7Qh/g+54nB6l85xGTFWlydQAjesO/pAIFPLfJiuCw24=";
  };

  sourceRoot = ".";

  postPatch = "cd CPP/7zip/Bundles/Alone2";

  makefile = "makefile.gcc";

  installPhase = ''
    ls -al _o
    install -D _o/7zz "$out"/bin/7zz
  '';

  meta.mainProgram = "7zz";
}
