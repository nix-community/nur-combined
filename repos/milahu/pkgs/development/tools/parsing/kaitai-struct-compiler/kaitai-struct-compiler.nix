{ lib
, stdenv
, fetchFromGitHub
, unzip
, jre
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "kaitai-struct-compiler";
  version = "0.10";

  src = builtins.fetchurl {
    url = "https://github.com/kaitai-io/kaitai_struct_compiler/releases/download/0.10/kaitai-struct-compiler-0.10.zip";
    sha256 = "sha256:0syiamp68ad5abb02dc4n81wlignjmqjxnhgd2sayn6h8v6dc49x";
  };

  formats = fetchFromGitHub {
    owner = "kaitai-io";
    repo = "kaitai_struct_formats";
    rev = "5edcbc59ee300e0e60dad044cd1ec6b1eb298a74";
    hash = "sha256-i9VJSHmEm7ueExMOm5WKQr3995iZCBJ5piN1dJQGWa4=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  buildPhase = ''
    mkdir $out
    cp -r bin lib $out
    wrapProgram $out/bin/kaitai-struct-compiler \
      --set JAVA_HOME ${jre} \
      --set KSPATH $formats
    rm $out/bin/kaitai-struct-compiler.bat
  '';

  meta = with lib; {
    description = "Kaitai Struct compiler for codegen from ksy files";
    homepage = "https://github.com/kaitai-io/kaitai_struct_compiler";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
