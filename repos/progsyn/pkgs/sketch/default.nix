{
  fetchurl,
  fetchFromGitHub,
  lib,
  makeWrapper,
  stdenv,
  bison,
  flex,
  autoconf,
  automake,
  libtool,
  jdk,
  which,
  coreutils,
}:
stdenv.mkDerivation rec {
  name = "sketch-${version}";
  version = "1.7.6";
  srcs = [
    (fetchurl
      {
        url = "https://people.csail.mit.edu/asolar/${name}.tar.gz";
        sha256 = "5cdac9ce841fd532215ff9ad8cb61a38cbdf6de0a635a669d0e46cdae72da707";
      })
    (fetchFromGitHub
      {
        name = "sketch-backend";
        owner = "asolarlez";
        repo = "sketch-backend";
        rev = "4e6085def4d33ef1455b64eada4b8fcddb259048";
        sha256 = "i2yTljbPVYfn61VWsdOS0KWuIDuwmK7xJKihrnHzqgY=";
      })
  ];
  sourceRoot = "sketch-backend";
  patches = [./backend.patch];

  nativeBuildInputs = [flex bison makeWrapper automake autoconf libtool];
  buildInputs = [jdk which coreutils];

  preConfigure = ''
    cd ..
    mkdir sketch
    mv ${name}/sketch-frontend sketch
    mv sketch-backend sketch
    rm -rf ${name}
    cd sketch/sketch-backend
    ./autogen.sh
  '';
  installPhase = ''
    mkdir -p $out
    cp -r ../sketch-backend $out
    cp -r ../sketch-frontend $out

    makeWrapper ${jdk}/bin/java $out/bin/sketch \
      --argv0 "sketch" \
      --add-flags "-cp $out/sketch-frontend/${name}-noarch.jar -ea sketch.compiler.main.seq.SequentialSketchMain --fe-inc=$out/sketch-frontend/sketchlib" \
      --set SKETCH_HOME $out/sketch-frontend/runtime
  '';

  meta = with lib; {
    description = "The sketch program synthesis tool";
    homepage = "https://github.com/asolarlez/sketch-backend";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
