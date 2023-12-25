{ stdenv
, autoPatchelfHook
, fetchurl
, xz
, e2fsprogs
, cyrus_sasl
, libkrb5
, libgcc
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
    mkdir -p $out
    tar -zxvf $src -C $out
    mv $out/mongosh-${version}-linux-x64/* $out
    rmdir $out/mongosh-${version}-linux-x64
  '';
  nativeBuildInputs = [
    autoPatchelfHook
  ];
}
