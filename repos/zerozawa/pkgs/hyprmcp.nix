{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  makeWrapper,
  python3Packages,
  hyprland,
}:
let
  rev = "13d5195e6a474078183cb031771be7a71b330bb6";
in
stdenvNoCC.mkDerivation rec {
  pname = "hyprmcp";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "stefanoamorelli";
    repo = pname;
    inherit rev;
    hash = "sha256-B6YwMm8yGLqahYDxgDEWk0Te2QmQPdCsIQ4+lqu6s44=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = with python3Packages; [
    mcp
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/hyprmcp
    cp -r hyprmcp/* $out/lib/hyprmcp/

    mkdir -p $out/bin
    makeWrapper ${python3Packages.python.interpreter} $out/bin/hyprmcp \
      --add-flags "$out/lib/hyprmcp/server.py" \
      --prefix PYTHONPATH : "${python3Packages.makePythonPath propagatedBuildInputs}" \
      --prefix PATH : "${hyprland}/bin"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Community MCP server for hyprctl";
    homepage = "https://github.com/stefanoamorelli/hyprmcp";
    license = with licenses; [ mit ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = pname;
  };
}
