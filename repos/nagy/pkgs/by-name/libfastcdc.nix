{
  lib,
  stdenv,
  fetchFromGitHub,
  writeTextFile,
}:

let
  program = writeTextFile {
    name = "prog.cc";
    text = ''
      #include "./fastcdc.h"
      int main() {
        cdc_ft::fastcdc::Chunker chunker (
          cdc_ft::fastcdc::Config{512 << 10, 1024 << 10, 2048 << 10},
          [](const uint8_t*data, size_t len) {
            std::cout << len << std::endl;
            if(std::getenv("FASTCDC_PRINT_DATA"))
              std::cout << std::string((const char*)data,len);
          });
        std::cin >> chunker;
        return 0;
      }
    '';
  };
in
stdenv.mkDerivation {
  pname = "libfastcdc";
  version = "unstable-2023-01-14";

  src = fetchFromGitHub {
    # fork with some conveniences
    owner = "nagy";
    repo = "cdc-file-transfer";
    rev = "f315e508c6cf5095d37730abe12ab146a3bc6089";
    sha256 = "sha256-mU3a1FcgPE0wBPNbuKOQ+RGhvg0sK3iW669uyFoEhu0=";
  };

  installPhase = ''
    mkdir -p $out/bin $out/include/
    install -Dm444 -t $out/include/ fastcdc/*.h
    $CXX -I $out/include ${program} -O3 -o $out/bin/fastcdc
  '';

  meta = with lib; {
    description = "Tools for synching and streaming files from Windows to Linux";
    homepage = "https://github.com/google/cdc-file-transfer";
    license = with licenses; [ asl20 ];
    mainProgram = "fastcdc";
  };
}
