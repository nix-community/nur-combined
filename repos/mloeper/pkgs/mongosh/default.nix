{ stdenv
, autoPatchelfHook
, fetchurl
, libgcc
, lib
}:
stdenv.mkDerivation rec {
  name = "mongosh";
  version = "2.1.1";
  src = fetchurl {
    url = "https://downloads.mongodb.com/compass/mongosh-${version}-linux-x64.tgz";
    sha256 = "l0CMUfERbZp+X1n+dBdjSq08ZUwjuXG2ynkCOvFcD7A=";
  };
  buildInputs = [
    libgcc
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    tar -zxvf $src -C $out
    mv $out/mongosh-${version}-linux-x64/bin/* $out/bin/
    rm -R $out/mongosh-${version}-linux-x64
  '';
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  meta = with lib; {
    homepage = "https://www.mongodb.com/products/tools/shell";
    description = "The quickest way to connect to MongoDB and Atlas to work with your data and manage your data platform";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "mongosh";
  };
}
