{ stdenv, python3, fetchFromGitHub, lib}:
stdenv.mkDerivation
 rec {
  pname = "lh2ctrl";
  version = "1.1.0";

  propagatedBuildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      bluepy
    ]))
  ];

  src = fetchFromGitHub {
    owner = "risa2000";
    repo = "lh2ctrl";
    rev = "v${version}";
    sha256 = "sha256-+I4NdxWbJtuEkRq4ZYuQSrSDzyzO2Rml+QJ1xthw4RE=";
  };

  installPhase = "install -Dm755 ${src + "/pylh2ctrl/lh2ctrl.py"} $out/bin/lh2ctrl";

  meta = with lib; {
    description = "Power management of Valve v2 lighthouses over Bluetooth LE";
    homepage = "https://github.com/risa2000/lh2ctrl";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}

