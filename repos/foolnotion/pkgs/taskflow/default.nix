{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "taskflow";
  version = "3.2.0";

  src = fetchFromGitHub {
    repo = "taskflow";
    owner = "taskflow";
    #rev = "v${version}";
    rev = "46bc2d310552aacb58ac28bc34aa8115bb0be43e";
    sha256 = "sha256-x1VGvsMSCpqhNV698VlwcgrZL4AwfXsM1j77ybR+1+8=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DTF_BUILD_TESTS=${if doCheck then "ON" else "OFF"}"
    "-DTF_BUILD_EXAMPLES=OFF"
  ];

  preConfigure = ''
      cmakeFlags="$cmakeFlags -DCMAKE_INSTALL_PREFIX=$out" 
  '';

  doCheck = false;

  meta = with lib; {
    description = "A general-purpose parallel and heterogeneous task programming system";
    homepage = "https://github.com/taskflow/taskflow";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
