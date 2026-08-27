{
  lib,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
}:
python3Packages.buildPythonApplication rec {
  pname = "flm-q4nx-converter";
  version = "unstable-2026-08-27";
  format = "other";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "FLM_Q4NX_Converter";
    rev = "dd0993cc0801c6ef98fbd57d64b8895c0730517f";
    sha256 = "sha256-k5PHQBoyRvmR8RMq5p89x+OGZiNs/Xj/58/OrYSYpyQ=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = with python3Packages; [
    einops
    gguf
    mpmath
    numpy
    safetensors
    torch
  ];

  installPhase =
    # bash
    ''
      runHook preInstall

      mkdir -p $out/bin $out/libexec/${meta.mainProgram}
      cp -r . "$out/libexec/${meta.mainProgram}"

      makeWrapper ${python3Packages.python.interpreter} $out/bin/${meta.mainProgram} \
        --prefix PYTHONPATH : "$PYTHONPATH" \
        --add-flags "$out/libexec/${meta.mainProgram}/convert.py"

      runHook postInstall
    '';

  meta = {
    description = "A converter for transferring gguf Q4_0, Q4_1 to FLM Q4NX";
    homepage = "https://github.com/ROCm/FLM_Q4NX_Converter";
    platforms = lib.systems.flakeExposed;
    license = lib.licenses.asl20;
    mainProgram = "flm-q4nx-converter";
  };
}
