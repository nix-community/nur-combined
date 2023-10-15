{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yyjson";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "ibireme";
    repo = "yyjson";
    rev = finalAttrs.version;
    hash = "sha256-uAh/AUUDudQr+1+3YLkg9KxARgvKWxfDZlqo8388nFY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = {
    description = "The fastest JSON library in C";
    homepage = "https://github.com/ibireme/yyjson";
    changelog = "https://github.com/ibireme/yyjson/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
