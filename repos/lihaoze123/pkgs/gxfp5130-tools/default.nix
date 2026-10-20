{ lib, stdenvNoCC, fetchFromGitHub, makeWrapper, python3, systemd, coreutils, gxfp5130-fprintd }:
let pin = lib.importJSON ../gxfp5130-libfprint/source.json;
in
stdenvNoCC.mkDerivation {
  pname = "gxfp5130-chicago-tools";
  version = "1";
  src = fetchFromGitHub { inherit (pin) owner repo rev hash; };
  sourceRoot = "source/tools";
  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ python3 ];
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    python3 -m unittest discover -s tests -v
    runHook postCheck
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec" "$out/bin"
    cp *.py "$out/libexec/"
    for name in import enroll verify; do
      makeWrapper ${python3}/bin/python3 "$out/bin/gxfp-chicago-$name" \
        --add-flags "$out/libexec/chicago.py $name" \
        --prefix PATH : ${lib.makeBinPath [ gxfp5130-fprintd systemd coreutils ]}
    done
    runHook postInstall
  '';
  meta = {
    description = "Native ChicagoHS fingerprint enrollment and verification tools";
    homepage = "https://github.com/lihaoze123/gxfp5130-chicago";
    license = lib.licenses.mit;
    mainProgram = "gxfp-chicago-verify";
    platforms = [ "x86_64-linux" ];
  };
}
