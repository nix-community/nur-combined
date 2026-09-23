{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  python3,
  stdenvNoCC,
}:

let
  python = python3.withPackages (ps: [
    ps.flask
    ps.click
    ps.numpy
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "modeltrace";
  version = "0-unstable-2026-09-23";

  src = fetchFromGitHub {
    owner = "xqy2006";
    repo = "ModelTrace";
    rev = "55a2e4a55170423b484d701e9a82ab62b268c811";
    hash = "sha256-+DPG1QBjsfzHr+UsXERu91af0FwuRX1UABtzki35u8M=";
  };

  nativeBuildInputs = [ makeWrapper ];
  patches = [ ./writable-data.patch ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/modeltrace" "$out/bin"
    cp *.py "$out/share/modeltrace/"
    cp -r data static templates "$out/share/modeltrace/"
    makeWrapper ${python}/bin/python "$out/bin/modeltrace" \
      --add-flags "-B $out/share/modeltrace/start.py"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Local web application for active language model attribution";
    homepage = "https://github.com/xqy2006/ModelTrace";
    license = lib.licenses.mit;
    mainProgram = "modeltrace";
    platforms = lib.platforms.unix;
  };
}
