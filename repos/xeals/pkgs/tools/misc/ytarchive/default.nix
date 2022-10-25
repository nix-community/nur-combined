{ stdenv
, lib
, fetchFromGitHub

, python3
, ffmpeg
}:

stdenv.mkDerivation rec {
  pname = "ytarchive";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "Kethsar";
    repo = "ytarchive";
    rev = "v${version}";
    sha256 = "xT45FF0ztWQXzQgYztl2YKiI2iGJfnCXgCMw8gOmxzM=";
  };

  propagatedBuildInputs = [
    python3
    ffmpeg
  ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    install -Dm00755 ytarchive.py $out/bin/ytarchive
  '';

  meta = with lib; {
    description = "Garbage Youtube livestream downloader";
    homepage = "https://github.com/Kethsar/ytarchive";
    license = licenses.mit;
    platforms = python3.meta.platforms;
  };
}
