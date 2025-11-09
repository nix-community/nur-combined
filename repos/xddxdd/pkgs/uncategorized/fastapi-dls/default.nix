{
  lib,
  sources,
  stdenv,
  openssl,
  python3,
  makeWrapper,
}:
let
  python = python3.withPackages (
    p: with p; [
      (lib.hiPrio fastapi)
      cryptography
      httpx
      markdown
      pycryptodome
      pytest
      python-dateutils
      python-dotenv
      python-jose
      sqlalchemy
      uvicorn
    ]
  );
in
stdenv.mkDerivation {
  inherit (sources.fastapi-dls) pname version src;

  nativeBuildInputs = [
    makeWrapper
    openssl
  ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    mkdir app/cert
    openssl genrsa -out app/cert/instance.private.pem 2048
    openssl rsa -in app/cert/instance.private.pem -outform PEM -pubout -out app/cert/instance.public.pem

    pushd test
    PYTHONPATH=$(pwd):$(pwd)/app ${python}/bin/python -m pytest main.py
    popd

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r * $out/opt/

    sed -i "s#\\.\\./#$out/opt/#g" $out/opt/app/main.py

    makeWrapper ${python}/bin/python $out/bin/fastapi-dls \
      --add-flags "-m" \
      --add-flags "uvicorn" \
      --add-flags "--app-dir" \
      --add-flags "$out/opt/app" \
      --add-flags "main:app"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Minimal Delegated License Service (DLS)";
    homepage = "https://gitea.publichub.eu/oscar.krause/fastapi-dls";
    license = lib.licenses.unfree;
    mainProgram = "fastapi-dls";
  };
}
