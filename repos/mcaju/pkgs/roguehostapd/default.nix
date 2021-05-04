{ stdenv
, lib
, buildPythonPackage
, fetchFromGitHub
, libnl
, openssl
}:

buildPythonPackage rec {
  pname = "roguehostapd";
  version = "1.0-45-g381b373";

  src = fetchFromGitHub {
    owner = "wifiphisher";
    repo = pname;
    rev = "381b373b4b3394d916e8c7a19b10d6c3c491bd13";
    sha256 = "10ckv7w6z1jwapccnl8wkhr4g3ad1xfvf3l672b4qyg55li25wmc";
  };

  patchPhase = ''
    substituteInPlace setup.py \
      --replace "shutil.rmtree('tmp')" 'pass'

    substituteInPlace roguehostapd/buildutil/build_files.py \
      --replace "/usr/include/libnl3" '${libnl.dev}/include/libnl3'
  '';

  buildInputs = [
    libnl
    openssl
  ];

  doCheck = false;

  meta = with lib; {
    description = "Hostapd fork including Wi-Fi attacks and providing Python bindings with ctypes.";
    homepage = "https://github.com/wifiphisher/roguehostapd";
    license = licenses.bsd3;
  };
}
