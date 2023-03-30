{ lib
, stdenv
, fetchFromGitHub
, cmake
, callPackage
}:

stdenv.mkDerivation rec {
  pname = "llama-cpp";
  version = "unstable-2023-03-30";

  src = fetchFromGitHub {
    owner = "ggerganov";
    repo = "llama.cpp";
    rev = "master-ed3c680";
    hash = "sha256-AnSux13Zcddi39vBaLwcEPYvhdvpFb915Ue58yVXYm8=";
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
      sed -i '${fixInterfaceIncludeDirectories}' examples/CMakeLists.txt

      cat <<\EOF >> CMakeLists.txt

      include(GNUInstallDirs)

      set_target_properties(main PROPERTIES OUTPUT_NAME "llama-chat")
      set_target_properties(embedding PROPERTIES OUTPUT_NAME "llama-embedding")
      set_target_properties(perplexity PROPERTIES OUTPUT_NAME "llama-perplexity")
      set_target_properties(quantize PROPERTIES OUTPUT_NAME "llama-quantize")

      install(
        TARGETS llama ggml main quantize embedding perplexity
        EXPORT llamaTargets
      )
      install(EXPORT llamaTargets
              FILE llamaConfig.cmake
              DESTINATION ''${CMAKE_INSTALL_LIBDIR}/cmake/llama
              NAMESPACE llama::)

      file(GLOB LLAMA_HEADERS CONFIGURE_DEPENDS "*.h" "*.hpp")
      install(FILES ''${LLAMA_HEADERS} DESTINATION ''${CMAKE_INSTALL_INCLUDEDIR})

      # TODO: Install .py scripts properly, with propagatedBuildInputs
      file(GLOB LLAMA_SCRIPTS CONFIGURE_DEPENDS "*.py")
      install(PROGRAMS ''${LLAMA_SCRIPTS} DESTINATION ''${CMAKE_INSTALL_BINDIR})
      EOF
    '';

  nativeBuildInputs = [
    cmake
  ];
  cmakeFlags = [
    "-DLLAMA_BUILD_EXAMPLES=ON"
  ];

  passthru.tests.chat-via-find-package = callPackage ./test.nix { };

  meta = with lib; {
    mainProgram = "llama-chat";
    description = "Port of Facebook's LLaMA model in C/C++";
    homepage = "https://github.com/ggerganov/llama.cpp";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
