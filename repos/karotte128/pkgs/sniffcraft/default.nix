{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, libGL, wayland, wayland-scanner, libxkbcommon, libx11, libxrandr, libxinerama, libxcursor, libxi, glfw,
  gameVersion ? "latest", withGui ? true, withEncryption ? true
}:

let
  boolToCmake = b: if b then "ON" else "OFF";
in

stdenv.mkDerivation rec {
  pname = "sniffcraft";
  version = "unstable-2026-04-11";

  src = fetchFromGitHub {
    owner = "adepierre";
    repo = "SniffCraft";
    rev = "3017a013b1a71a8465275c7463a2cc1f15535c16";
    hash = "sha256-zQzbRDfwr2EYLwi24pV6wanndPzAd7tDJM0V/D2Q9Sw=";
    fetchSubmodules = true;
  };

  # vendored ImGui
  imguiSrc = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "v1.92.5";
    hash = "sha256-9A+qRsrsFxLAeDeV60qFTiBmg2XBKgERAxKZgD8AwTM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libGL
    wayland
    libxkbcommon
    glfw
    libx11
    libxrandr
    libxinerama
    libxcursor
    libxi
  ];

  postPatch = ''
# use GLFW system package
cat > cmake/glfw.cmake <<'EOF'
find_package(glfw3 REQUIRED)
EOF

# replace imgui.cmake to use vendored imgui
cat > cmake/imgui.cmake <<EOF
add_library(imgui STATIC
${imguiSrc}/imgui.cpp
${imguiSrc}/imgui_draw.cpp
${imguiSrc}/imgui_tables.cpp
${imguiSrc}/imgui_widgets.cpp
${imguiSrc}/misc/cpp/imgui_stdlib.cpp
${imguiSrc}/backends/imgui_impl_glfw.cpp
${imguiSrc}/backends/imgui_impl_opengl3.cpp
)
target_include_directories(imgui PUBLIC ${imguiSrc})
target_link_libraries(imgui PUBLIC glfw OpenGL::GL)
set_property(TARGET imgui PROPERTY CXX_STANDARD 11)
EOF
'';

  cmakeFlags = [
    "-DGAME_VERSION=${gameVersion}"
    "-DSNIFFCRAFT_WITH_GUI=${boolToCmake withGui}"
    "-DSNIFFCRAFT_WITH_ENCRYPTION=${boolToCmake withEncryption}"
    "-Dglfw3_DIR=${glfw}/lib/cmake/glfw3"
  ];

  postInstall = ''
mkdir -p $out/bin
cp $NIX_BUILD_TOP/source/bin/* $out/bin/
'';

  meta = with lib; {
    description = "Minecraft packet proxy/sniffer";
    homepage = "https://github.com/adepierre/SniffCraft";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}