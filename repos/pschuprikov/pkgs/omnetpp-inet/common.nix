{ version, sha256 }:
{ stdenv, fetchurl, python3, perl, openscenegraph, libGL, omnetpp, makeWrapper, mode ? "release" }:
stdenv.mkDerivation rec {
  pname = "inet";
  name = "${pname}-${version}";
  inherit version;
  src = fetchurl {
    url = "https://github.com/inet-framework/${pname}/releases/download/v${version}/${pname}-${version}-src.tgz";
    inherit sha256;
  };
  configureScript = "make makefiles";
  makeFlags = [ "MODE=${mode}" ];
  dontAddPrefix = true;
  nativeBuildInputs = [ python3 perl makeWrapper ];
  buildInputs = [ openscenegraph libGL omnetpp ];
  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/lib $out/share/inet
    cp -vr bin $out/
    cp -vr images $out/share/inet/
    for f in $(find src -iname "*.ned"); do
      dir=$out/share/inet/ned/$(dirname ''${f#src/})
      mkdir -p $dir
      cp -v $f $dir
    done
    install -t $out/lib out/gcc-release/src/libINET.so

    mkdir -p $out/include
    for f in $(find src -iname "*.h"); do
      dir=$out/include/$(dirname ''${f#src/})
      mkdir -p $dir
      cp -v $f $dir
    done
  '';

  preFixup = ''
    substituteInPlace $out/bin/inet \
      --replace "/../src" "/../lib"
    wrapProgram $out/bin/inet \
      --prefix PATH ":" "${omnetpp}/bin" \
      --prefix NEDPATH ";" "$out/share/inet/ned" \
      --set INET_OMNETPP_OPTIONS "--image-path=$out/share/inet/images"
  '';
}
