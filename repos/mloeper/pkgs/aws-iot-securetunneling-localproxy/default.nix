{ lib, stdenv, pkgs, fetchFromGitHub, fetchurl, protobuf3_19, gcc12Stdenv, ... }:

# using current gcc version 13.2.0 introduced build errors regarding decltype
gcc12Stdenv.mkDerivation {
  pname = "aws-iot-securetunneling-localproxy";
  version = "3.1.0";

  src = [
    (fetchFromGitHub
      {
        owner = "aws-samples";
        repo = "aws-iot-securetunneling-localproxy";
        rev = "b6c31b442fa6d4c930e705d2853efd73dadff169";
        sha256 = "sha256-QW41uPyuRpgUx6e1p8NqdH03zQJEAx3kjIQSHXs8h/k=";
        name = "src";
      })
    (fetchurl {
      url = "https://www.amazontrust.com/repository/AmazonRootCA1.pem";
      hash = "sha256-LEOVLungAP8qzE4u0Il8CnKtX6csPZNOgXQcvVTwW9E=";
      name = "AmazonRootCA1.pem";
    })
  ];

  sourceRoot = "src";

  unpackCmd = ''
    cp $curSrc AmazonRootCA1.pem
  '';

  buildInputs = with pkgs; [
    (boost181.override
      { enableShared = false; enableStatic = true; })
    openssl
    protobuf3_19
    zlib
    catch2
    cmake
    icu
  ];

  installPhase = ''
    install -d $out/bin
    cp ./bin/localproxy $out/bin/

    install -d $out/share/certs
    cp ./../../AmazonRootCA1.pem $out/share/certs/
  '';

  buildPhase = ''
    cmake ..
    make
  '';

  meta = with lib; {
    homepage = "https://github.com/aws-samples/aws-iot-securetunneling-localproxy";
    description = "AWS Iot Secure Tunneling local proxy reference C++ implementation";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "localproxy";
  };
}
