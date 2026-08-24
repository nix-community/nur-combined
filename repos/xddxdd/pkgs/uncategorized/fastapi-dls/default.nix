{
  fetchFromGitHub,
  lib,
  nix-update-script,
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
      python-dateutil
      python-dotenv
      python-jose
      sqlalchemy
      uvicorn
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "fastapi-dls";
  version = "2.0.1-unstable-2025-05-13";
  src = fetchFromGitHub {
    owner = "GreenDamTan";
    repo = "fastapi-dls_mirror";
    rev = "52e9f2cae9e2ae791e810593a99d642763431806";
    hash = "sha256-nTWvnoHIOt1jHv2m9JGPhFithu2/VZdl+Ju2n6woVHY=";
  };
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
    PYTHONPATH=$(pwd):$(pwd)/app ${lib.getExe python} -m pytest main.py
    popd

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r * $out/opt/

    sed -i "s#\\.\\./#$out/opt/#g" $out/opt/app/main.py

    makeWrapper ${lib.getExe python} $out/bin/fastapi-dls \
      --add-flags "-m" \
      --add-flags "uvicorn" \
      --add-flags "--app-dir" \
      --add-flags "$out/opt/app" \
      --add-flags "main:app"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Minimal Delegated License Service (DLS)";
    homepage = "https://gitea.publichub.eu/oscar.krause/fastapi-dls";
    license = lib.licenses.unfree;
    mainProgram = "fastapi-dls";
  };
})
