{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
}:

stdenv.mkDerivation rec {
  pname = "yyjson";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "ibireme";
    repo = "yyjson";
    rev = version;
    hash = "sha256-uAh/AUUDudQr+1+3YLkg9KxARgvKWxfDZlqo8388nFY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with lib; {
    description = "The fastest JSON library in C";
    homepage = "https://github.com/ibireme/yyjson";
    changelog = "https://github.com/ibireme/yyjson/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
