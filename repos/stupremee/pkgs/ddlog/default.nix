{ stdenv, autoPatchelfHook, fetchurl, gnutar }:

stdenv.mkDerivation rec {
  pname = "ddlog";
  version = "0.31.0";

  # TODO: Build from source
  #src = fetchFromGitHub {
  #owner = "vmware";
  #repo = "differential-datalog";
  #rev = "v${version}";
  #sha256 = "sha256-l4kLC64OOcPBRn2VSxqG/FIxLxxPozDk78fG50gI3YI=";
  #};

  src = fetchurl {
    url =
      "https://github.com/vmware/differential-datalog/releases/download/v${version}/ddlog-v0.31.0-20201124092921-linux.tar.gz";
    sha256 = "sha256-zzFM6kLS70hWY+yBVFY7UaKXxEYjCXa/kPZ7UyXpwMk==";
  };

  nativeBuildInputs = [ gnutar ];
  dontBuild = true;

  unpackPhase = ''
    tar xf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r -a ddlog/* $out
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/vmware/differential-datalog";
    description = "An incremental programming language ";
    platforms = platforms.linux;
  };
}
