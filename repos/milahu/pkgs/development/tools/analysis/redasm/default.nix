/*

  spoiler: redasm is an ugly peace of crap

  maybe lib/LibREDasm.so is usable for some special-purpose reversing

  better general-purpose tools:
  https://github.com/NationalSecurityAgency/ghidra
  https://github.com/rizinorg/cutter

  this takes 1 hour to build with a 2x 2x 2.4GHz cpu

  todo? split build to cache modules
  cmake2nix: convert all "add_subdirectory" and "CPMAddPackage" to separate derivations
  produce static libraries: somelib.a (not somelib.so)
  CMakeLists.txt
    add_subdirectory(libs/qhexview EXCLUDE_FROM_ALL)
    add_subdirectory(LibREDasm)
    add_subdirectory(submodules/plugins)
    add_subdirectory(submodules/assemblers)
    add_subdirectory(submodules/loaders)
    add_subdirectory(submodules/database)

*/

{ lib
, stdenv
, llvmPackages
, fetchFromGitHub
, cmake
, pkg-config
, qt5
, qt6
, nlohmann_json
, spdlog
#, python3
#, capstone # TODO? source/submodules/assemblers/capstonebundle/CMakeLists.txt -> capstone-static
}:

#stdenv.mkDerivation rec {
llvmPackages.stdenv.mkDerivation rec {
  pname = "redasm";
  #version = "3.0.0-beta5"; # old: 2021-05-16
  # CMakeLists.txt: set(REDASM_VERSION_BASE "3.0-BETA7")
  version = "3.0.0-beta7-${versionDate}-${versionRev}";
  versionDate = "2024-02-24";
  versionRev = builtins.substring 0 8 src.rev;

  # https://github.com/REDasmOrg/REDasm
  src = fetchFromGitHub {
    owner = "REDasmOrg";
    repo = "REDasm";
    rev = "6e8bbaec4e7afed7b847e0d9033c12507fa61cf6";
    hash = "sha256-fyGe2MsCvQrnjIFhsGnaYN5ZdW30rkdzWVj46HPYziU=";
    fetchSubmodules = true;
  };

  # CMakeLists.txt: CPMAddPackage(NAME KDDockWidgets
  # https://github.com/KDAB/KDDockWidgets
  srcKDDockWidgets = fetchFromGitHub {
    owner = "KDAB";
    repo = "KDDockWidgets";
    rev = "v1.7.0";
    hash = "sha256-k5Hn9kxq1+tH5kV/ZeD4xzQLDgcY4ACC+guP7YJD4C8=";
  };

  # patch REDASM_BUILD_TIMESTAMP: "%Y%m%d" would eval to "19800101"
  postUnpack = ''
    pushd $sourceRoot
    ln -s $srcKDDockWidgets KDDockWidgets
    popd
  '';

  patches = [
    ./CMakeLists.txt.diff
    ./LibREDasm-CMakeLists.txt.diff
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        'set(REDASM_GIT_VERSION "unknown")' \
        'set(REDASM_GIT_VERSION "${versionRev}")' \
      --replace-fail \
        'string(TIMESTAMP REDASM_BUILD_TIMESTAMP "%Y%m%d")' \
        'set(REDASM_BUILD_TIMESTAMP "${versionDate}")' \

    # Generating documentation to /build/source/build/LibREDasm/docs
    substituteInPlace LibREDasm/cmake/functions.cmake \
      --replace-fail \
        'message("Generating documentation")' \
        'message("Generating documentation to ''${RDAPI_DOC_OUT}")' \

    # fix: cc1plus: warning: command-line option '-std=c99' is valid for C/ObjC but not for C++
    # fix: error: invalid argument '-std=c99' not allowed with 'C++'
    substituteInPlace submodules/assemblers/x86/zydis/dependencies/zycore/CMakeLists.txt \
      --replace-fail \
        'target_compile_options("''${target}" PRIVATE "-std=c99")' "" \
  '';

  # the "docs" are just one doc.json file with the API of libredasm
  /*
  postInstall = ''
    mkdir -p $out/share/docs
    cp -r LibREDasm/docs $out/share/docs/redasm
  '';
  */

  nativeBuildInputs = [
    cmake
    # FIXME? -- Could NOT find PkgConfig (missing: PKG_CONFIG_EXECUTABLE)
    pkg-config
    qt5.wrapQtAppsHook
    #python3 # build docs
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtx11extras
    qt5.qttools # Qt5LinguistToolsConfig.cmake
    nlohmann_json # for LibREDasm
    spdlog # for LibREDasm
    #capstone
    #zydis
  ];

  meta = with lib; {
    description = "The OpenSource Disassembler";
    homepage = "https://github.com/REDasmOrg/REDasm";
    changelog = "https://github.com/REDasmOrg/REDasm/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "REDasm";
    platforms = platforms.all;
  };
}
