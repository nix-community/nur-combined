{ stdenv
, cmake
, llama-cpp
}:

stdenv.mkDerivation rec {
  pname = "chat-via-find-package";
  version = llama-cpp.version;

  src = ./.;

  buildInputs = [
    llama-cpp
  ];
  nativeBuildInputs = [
    cmake
  ];
}
