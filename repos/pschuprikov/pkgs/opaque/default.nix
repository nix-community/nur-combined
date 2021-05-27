{ fetchFromGitHub, lib, fetchurl, writeText, stdenv, jdk, sbt, cmake, python2, openenclave, openssl, mbedtls, intel-sgx-sdk, intel-sgx-psw, unzip }:
let 
  src = fetchFromGitHub {
    owner = "mc2-project";
    repo = "opaque";
    rev = "v0.2";
    sha256 = "yC/JY7/EpcXZ3QcOE+UT4DrBlvNNDKzltMDzBzY61eo=";
  };

  depsInstallPhase = ''
    mkdir -p $out
    cp -R $PWD/.ivy2 $out/
  '';

  depsFixupPhase = ''
      find $out/.ivy2 -type f -name "*.properties" -delete
      rm -rf $out/.ivy2/cache/org.scala-sbt/org.scala-sbt-compiler-interface-*
  '';

  launcher = stdenv.mkDerivation {
    name = "sbt-launcher";
    inherit src;

    buildInputs = [ sbt ];
    buildPhase = ''
      sbt --sbt-boot $PWD/.sbt/boot --ivy $PWD/.ivy2 exit
    '';

    installPhase = depsInstallPhase;
    fixupPhase = depsFixupPhase;

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-7WMVIP6Zk7qk4Mpqs3am5VeJ8W4PZckU6th1h09kPbE=";
  };

  repos = online: drvs: writeText "repos" ("[repositories]\n" +
    lib.concatMapStrings (drv: ''
      ${drv.name}-one: file://${drv}/.ivy2/cache, [organization]/[module]/[artifact]-[revision].[ext], [organization]/[module]/[type]s/[artifact]-[revision](-[classifier]).jar
      ${drv.name}-two: file://${drv}/.ivy2/cache, [organization]/[module]_[scalaVersion]/[artifact]-[revision].[ext], [organization]/[module]_[scalaVersion]/[type]s/[artifact]-[revision].jar
      ${drv.name}-three: file://${drv}/.ivy2/cache, scala_[scalaVersion]/sbt_[sbtVersion]/[organization]/[module]/[artifact]-[revision].[ext], scala_[scalaVersion]/sbt_[sbtVersion]/[organization]/[module]/[type]s/[artifact]-[revision].jar
    '') drvs);

  dependencies = stdenv.mkDerivation {
    name = "sbt-deps";
    inherit src;

    buildInputs = [ sbt ];

    buildPhase = ''
      sbt --sbt-boot .sbt/boot --ivy $PWD/.ivy2 -Dsbt.repository.config=${repos true [launcher]} update
      sbt --sbt-boot .sbt/boot --ivy $PWD/.ivy2 -Dsbt.repository.config=${repos true [launcher]} update
    '';

    installPhase = depsInstallPhase;
    fixupPhase = depsFixupPhase;

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-MaZ420uAmAA4Ejs8ut3D1KSCZOVQ/MceQccUWcP8Xaw=";
  };

  intel-cert = fetchurl {
    url = "https://software.intel.com/sites/default/files/managed/7b/de/RK_PUB.zip";
    sha256 = "sha256-GHCJcsmtklvrisbnWNY1YeLpTraREVHBkrjyK86dSbw=";
  };

  flatbuffers_src = fetchurl {
    url = "https://github.com/google/flatbuffers/archive/v1.7.0.zip";
    sha256 = "sha256-ICdM75yF3xzTWmmStCId1AEgXWJy8RqKZK1h1rYpvJo=";
  };

in stdenv.mkDerivation {
  name = "opaque-v0.2";

  inherit src;

  buildInputs = [ sbt python2 ];
  nativeBuildInputs = [ cmake openenclave openssl mbedtls unzip ];

  dontUseCmakeConfigure = true;

  patchPhase = ''
    substituteInPlace ./build.sbt \
      --replace "https://software.intel.com/sites/default/files/managed/7b/de/RK_PUB.zip" "file://${intel-cert}" \
      --replace "https://github.com/google/flatbuffers/archive/v\$flatbuffersVersion.zip" "file://${flatbuffers_src}" \
      --replace "\"cmake\"" \"${cmake}/bin/cmake\"
    patchShebangs data
    patchShebangs src/enclave
  '';

  NIX_CFLAGS_COMPILE = "-Wno-ignored-qualifiers -Wno-class-memaccess -Wno-pessimizing-move -L${intel-sgx-sdk}/usr/lib64 -L${intel-sgx-psw}/usr/lib64";

  buildPhase = ''
    openssl ecparam -name prime256v1 -genkey -noout -out private_key.pem
    export SGX_SDK=${intel-sgx-sdk}/opt/intel/sgxsdk
    export SPARKSGX_DATA_DIR=$PWD/data
    export PRIVATE_KEY_PATH=$PWD/private_key.pem
    sbt --sbt-boot $PWD/.sbt/boot --ivy $PWD/.ivy2 -Dsbt.repository.config=${repos false [launcher dependencies]} package
  '';

  installPhase = ''
    mkdir -p $out
    cp -r target/enclave/lib $out/
    mkdir -p $out/share/java
    cp target/scala-*/*.jar $out/share/java/
  '';
}
