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
  version = "0-unstable-2026-09-27";

  src = fetchFromGitHub {
    owner = "xqy2006";
    repo = "ModelTrace";
    rev = "df3a0f9d3e054c0dc02d6d586686db8daf8fa7c8";
    hash = "sha256-vrqgcFC9/noEuE7+5tqs1QKvRUDK+2gwa9KR9B1TcKo=";
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
