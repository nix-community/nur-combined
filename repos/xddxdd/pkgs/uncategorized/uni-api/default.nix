{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  stdenv,
  python3,
  makeWrapper,
  curl,
}:
let
  python = python3.withPackages (
    p: with p; [
      aiofiles
      aiosqlite
      cryptography
      fastapi
      greenlet
      h2
      httpx
      httpx-socks
      msgspec
      pillow
      pytest
      python-multipart
      ruamel-yaml
      sqlalchemy
      uvicorn
      watchfiles
      xue
      zstandard
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "uni-api";
  version = "1.7.271-unstable-2026-09-10";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "68fef253bd04753ca9b2bc61df862706d7ceb682";
    fetchSubmodules = true;
    hash = "sha256-jGHN4erpJF7W2FZivEMBhSbwYIYM+VP5cYCwIXzS9vw=";
  };
  nativeBuildInputs = [
    makeWrapper
    curl
  ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    ${python}/bin/python -c "import uni_api.app"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r * $out/opt/

    makeWrapper ${python}/bin/python $out/bin/uni-api \
      --add-flags "-m" \
      --add-flags "uvicorn" \
      --add-flags "--app-dir" \
      --add-flags "$out/opt" \
      --add-flags "main:app"

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/yym68686/uni-api";
    tagPrefix = "v";
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs across multiple backend services";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api";
  };
})
