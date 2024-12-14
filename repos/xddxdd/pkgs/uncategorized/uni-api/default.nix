{
  lib,
  sources,
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
      pillow
      pytest
      python-multipart
      ruamel-yaml
      sqlalchemy
      uvicorn
      watchfiles
      xue
    ]
  );
in
stdenv.mkDerivation {
  inherit (sources.uni-api) pname version src;

  nativeBuildInputs = [
    makeWrapper
    curl
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r * $out/opt/
    substituteInPlace $out/opt/main.py \
      --replace-fail '"./static"' "\"$out/opt/static\""

    makeWrapper ${python}/bin/python $out/bin/uni-api \
      --add-flags "-m" \
      --add-flags "uvicorn" \
      --add-flags "--app-dir" \
      --add-flags "$out/opt" \
      --add-flags "main:app"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs. Call multiple backend services through a unified API interface";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api";
  };
}
