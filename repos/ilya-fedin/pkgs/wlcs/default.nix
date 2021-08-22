{ stdenv, lib, fetchFromGitHub, pkg-config, cmake, ninja
, boost, wayland, gtest
}:

with lib;

stdenv.mkDerivation rec {
  pname = "wlcs";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "MirServer";
    repo = "wlcs";
    rev = "v${version}";
    sha256 = "paQZMb+efQ5GRGxKpaz2DE6C+/LFfFM2i2/3bqMuMI8=";
  };

  postPatch = ''
    substituteInPlace cmake/FindGtestGmock.cmake \
      --replace 'string(REPLACE gtest gmock GMOCK_LIBRARY ''${GTEST_LIBRARY})' 'string(REPLACE libgtest libgmock GMOCK_LIBRARY ''${GTEST_LIBRARY})'
  '';

  nativeBuildInputs = [ pkg-config cmake ninja ];

  buildInputs = [
    boost wayland gtest
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Wayland Conformance Test Suite";
    longDescription = ''
      wlcs aspires to be a protocol-conformance-verifying test suite
      usable by Wayland compositor implementors.

      It is growing out of porting the existing Weston test suite to be
      run in Mir's test suite, but it is designed to be usable by any
      compositor.
    '';
    license = [ licenses.gpl2Only licenses.gpl3Only ];
    platforms = platforms.linux;
    homepage = https://mir-server.io;
    changelog = "https://github.com/MirServer/wlcs/releases/tag/v{version}";
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
