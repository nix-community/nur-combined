{
  aria2,
  cacert,
  curl,
  gitSetupHook,
  lib,
  python3,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "git-lfs-agent-aria2";
  version = "1";

  dontUnpack = true;
  setupHook = ./setup-hook.sh;
  propagatedBuildInputs = [
    cacert
    gitSetupHook
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    substitute ${./agent.py} "$out/bin/git-lfs-agent-aria2" \
      --subst-var-by python ${python3.interpreter} \
      --subst-var-by curl ${lib.getExe curl} \
      --subst-var-by aria2 ${lib.getExe aria2}
    chmod +x "$out/bin/git-lfs-agent-aria2"
    runHook postInstall
  '';

  meta = {
    description = "Standalone Git LFS transfer agent using aria2";
    mainProgram = "git-lfs-agent-aria2";
  };
}
