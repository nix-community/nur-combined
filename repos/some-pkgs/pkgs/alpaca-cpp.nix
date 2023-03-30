{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "alpaca-cpp";
  version = "unstable-2023-03-30";

  src = fetchFromGitHub {
    owner = "antimatter15";
    repo = "alpaca.cpp";
    rev = "81bd894";
    hash = "sha256-izeL66to0/hwTsZopEPz1e08TOUoVSWrA1YKbBYnUTk=";
  };

  postPatch =
    let
      includeDirectoriesOld = ''
        include_directories(\([^)]\+\) .)'';
      includeDirectoriesNew = ''
        include_directories(\1 "$<BUILD_INTERFACE:''${CMAKE_CURRENT_SOURCE_DIR}>" "$<INSTALL_INTERFACE:''${CMAKE_INSTALL_INCLUDEDIR}>")'';
      fixInterfaceIncludeDirectories = "s|${includeDirectoriesOld}|${includeDirectoriesNew}|";
    in
    ''
      substituteInPlace CMakeLists.txt --replace "cmake_minimum_required(VERSION 3.12)" "cmake_minimum_required(VERSION 3.14) # proper install()"
      sed -i '${fixInterfaceIncludeDirectories}' CMakeLists.txt

      cat <<\EOF >> CMakeLists.txt

      include(GNUInstallDirs)

      set_target_properties(chat PROPERTIES OUTPUT_NAME "alpaca-chat")
      set_target_properties(quantize PROPERTIES OUTPUT_NAME "alpaca-quantize")

      install(TARGETS chat ggml quantize EXPORT alpacaTargets)
      install(EXPORT alpacaTargets
              FILE alpacaTargets.cmake
              DESTINATION ''${CMAKE_INSTALL_LIBDIR}/cmake/alpaca
              NAMESPACE alpaca::)
      EOF
    '';

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    mainProgram = "alpaca-chat";
    description = "Locally run an Instruction-Tuned Chat-Style LLM";
    homepage = "https://github.com/antimatter15/alpaca.cpp";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
