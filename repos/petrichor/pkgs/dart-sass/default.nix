{ stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "dart-sass";
  version = "1.32.8";

  src = fetchurl {
    url =
      "https://github.com/sass/${pname}/releases/download/${version}/${pname}-${version}-linux-x64.tar.gz";
    sha256 = "0dm30x4hmcfz726ss629icvm0c92hbkkvkmjdpr2jdy12s5ygk28";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    mkdir -p $out/bin
    mv sass $out/bin
  '';
}
