{ lib
, stdenv
}:

stdenv.mkDerivation {
  name = "imagename2id";
  src = ./src;
  buildCommand = ''
    mkdir -p $out/bin
    set -x
    g++ -o $out/bin/imagename2id $src/imagename2id.cpp
    set +x
  '';
  # TODO test

  meta = with lib; {
    description = "get short id from image name";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "imagename2id";
    platforms = platforms.all;
  };
}
