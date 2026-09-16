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
  version = "0-unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "xqy2006";
    repo = "ModelTrace";
    rev = "3f0dd2f4b451ad424f3b165a108a468efe4d4d81";
    hash = "sha256-0InSHeJBt+7k5i/spOxCGNiIT+tLlobfElH06U84ECA=";
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
