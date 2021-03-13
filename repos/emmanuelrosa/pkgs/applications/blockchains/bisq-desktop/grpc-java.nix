{ stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  name = "protoc-gen-grpc-java";
  version = "1.25.0";
  src = fetchurl {
    url = "https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/${version}/protoc-gen-grpc-java-${version}-linux-x86_64.exe";
    sha256 = "1hhfr90nincj4p2fbhh74g5bx0mllqnhg603i2j62whg9apw04m7";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  dontUnpack = true;

  installPhase = ''
    install -m755 -D $src $out/bin/protoc-gen-rpc-java
  '';
}
