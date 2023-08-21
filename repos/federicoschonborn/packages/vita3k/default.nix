{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, pkg-config
, boost
, dbus
, openssl
, SDL2
}:

stdenv.mkDerivation {
  pname = "vita3k";
  version = "unstable-2023-08-19";

  src = fetchFromGitHub {
    owner = "Vita3K";
    repo = "Vita3K";
    rev = "44d8c5da9cc6bed0b670099f4d131296ff8acf25";
    hash = "sha256-VQ9pn0QILMLHbJMl00/851FvsIXDePlGpc5bBFziNbA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    (boost.override { enableStatic = true; })
    dbus
    openssl
    SDL2
  ];

  cmakeFlags = [
    "-DUSE_DISCORD_RICH_PRESENCE=NO"
  ];

  meta = with lib; {
    description = "Experimental PlayStation Vita emulator";
    homepage = "https://github.com/Vita3K/Vita3K";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ federicoschonborn ];
    # external/dynarmic/src/dynarmic/CMakeLists.txt: Cannot find source file: ir/var/empty/constant_propagation_pass.cpp
    broken = true;
  };
}
