{ lib
, stdenvNoCC
, fetchurl
#, protobuf
, autoPatchelfHook
}:

stdenvNoCC.mkDerivation rec {
  pname = "grpc-java";
  #version = "1.65.0";
  version = "1.42.1";

  # io.grpc:protoc-gen-grpc-java
  src = fetchurl {
    url = "https://repo.maven.apache.org/maven2/io/grpc/protoc-gen-grpc-java/${version}/protoc-gen-grpc-java-${version}-linux-x86_64.exe";
    hash = "sha256-VZa2nrae1Qi8aTB/FDQL5wK97i/w7TPByv3gKu/J+q8=";
  };

  dontUnpack = true;

  #dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  #dontPatchELF = true;

  buildPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/protoc-gen-grpc-java
    chmod +x $out/bin/protoc-gen-grpc-java
  '';

  meta = with lib; {
    description = "The Java gRPC implementation. HTTP/2 based RPC [binary build]";
    homepage = "https://github.com/grpc/grpc-java";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "protoc-gen-grpc-java";
    platforms = platforms.all;
  };
}
