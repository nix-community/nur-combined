{
  lib,
  sources,
  stdenv,
  python3,
  makeWrapper,
  ...
}:
let
  python = python3.withPackages (
    p: with p; [
      dateutils
      (lib.hiPrio fastapi)
      markdown
      pycryptodome
      python-dotenv
      python-jose
      sqlalchemy
      uvicorn
    ]
  );
in
stdenv.mkDerivation {
  inherit (sources.fastapi-dls) pname version src;

  nativeBuildInputs = [ makeWrapper ];

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

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Minimal Delegated License Service (DLS)";
    homepage = "https://gitea.publichub.eu/oscar.krause/fastapi-dls";
    license = licenses.unfree;
  };
}
