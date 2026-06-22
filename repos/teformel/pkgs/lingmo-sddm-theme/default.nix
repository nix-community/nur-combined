{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "lingmo-sddm-theme";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-sddm-theme";
    rev = "3b38408325e387452cd1b28ea2dbefbe584278c8";
    hash = "sha256-S9un0XAEVy9d6A40U2LuKtrrCxbNtooGSoFdTvEShsA=";
  };

    postPatch = ''
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/usr/|DESTINATION "|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/etc/|DESTINATION "etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /usr/|DESTINATION |g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc/|DESTINATION etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc|DESTINATION etc|g' {} +
  '';

  nativeBuildInputs = [
    cmake
  ];
}
