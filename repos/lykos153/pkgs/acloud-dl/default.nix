{ lib
, python311
, fetchFromGitHub
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "acloud-dl";
  version = "0ca6253bbe6257a2fb8561bbd629e6e4c4546e43";

  src = fetchFromGitHub {
    owner = "r0oth3x49";
    repo = pname;
    rev = "${version}";
    hash = "sha256-4qfCf6uHlaMGsMV8x4dijTS3Mw8PWkQkUBo34ipFvrY=";
  };
  propagatedBuildInputs = [
    (python311.withPackages (pythonPackages: with pythonPackages; [
      requests
      six
      colorama
      unidecode
      pyopenssl
    ]))
  ];
  installPhase = ''
    mkdir -p $out/opt/acloud-dl
    cp -r ./acloud $out/opt/acloud-dl/
    install -Dm755 ./acloud-dl.py $out/opt/acloud-dl/acloud-dl.py
    install -Dm755 ./renamesuffix.py $out/opt/acloud-dl/renamesuffix.py
    mkdir -p $out/bin
    ln -s ../opt/acloud-dl/acloud-dl.py $out/bin/acloud-dl
  '';

  meta = with lib; {
    description = "A cross-platform python based utility to download courses from acloud.guru for personal offline use. ";
    homepage = "https://github.com/r0oth3x49/acloud-dl";
    license = licenses.mit;
  };
}
