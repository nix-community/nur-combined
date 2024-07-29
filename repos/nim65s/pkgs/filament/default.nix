{
  lib,
  clangStdenv,
  fetchFromGitHub,
  cmake,
  python3Packages,
  libglvnd,
  libcxx,
  libXi,
  libXcomposite,
  libXxf86vm,
  libX11
}:

clangStdenv.mkDerivation rec {
  pname = "filament";
  version = "1.53.1";

  src = fetchFromGitHub {
    owner = "google";
    repo = "filament";
    rev = "v${version}";
    hash = "sha256-CR2y92lBPHs6Idxbbj4P913TBQwIi7ZAEV2oK/eBw20=";
  };

  nativeBuildInputs = [
    cmake
    python3Packages.python
    libglvnd
    libcxx
    libXi
    libXcomposite
    libXxf86vm
    libX11
  ];

  postPatch = ''
    substituteInPlace third_party/draco/src/draco/io/file_utils.h \
      --replace-fail "#include <vector>" "#include <vector>
      #include <cstdint>"
    substituteInPlace tools/glslminifier/src/GlslMinify.h \
      --replace-fail "#include <string>" "#include <string>
      #include <cstdint>"
    substituteInPlace libs/utils/include/utils/memalign.h \
      --replace-fail "::posix_memalign" "std::ignore = ::posix_memalign" \
      --replace-fail "#include <type_traits>" "#include <type_traits>
      #include <tuple>"
    substituteInPlace libs/gltfio/src/extended/TangentsJobExtended.cpp \
      --replace-fail "#include <memory>" "#include <memory>
      #include <cstring>"
    patchShebangs --build build/linux/combine-static-libs.sh
  '';

  cmakeFlags = [
    (lib.cmakeBool "USE_STATIC_LIBCXX" clangStdenv.isDarwin)
    (lib.cmakeBool "FILAMENT_SUPPORTS_METAL" clangStdenv.isDarwin)
    (lib.cmakeBool "FILAMENT_SUPPORTS_VULKAN" clangStdenv.isDarwin)
  ];

  meta = with lib; {
    description = "Filament is a real-time physically based rendering engine for Android, iOS, Windows, Linux, macOS, and WebGL2";
    homepage = "https://github.com/google/filament";
    license = licenses.asl20;
    maintainers = with maintainers; [ nim65s ];
    mainProgram = "filament";
    platforms = platforms.all;
  };
}
