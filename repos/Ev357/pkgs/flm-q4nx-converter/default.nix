{
  lib,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
}:
python3Packages.buildPythonApplication rec {
  pname = "flm-q4nx-converter";
  version = "0-unstable-2026-08-27";
  format = "other";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "FLM_Q4NX_Converter";
    rev = "d1d5232d0b82871bf5265e990fa2d26cdad22327";
    sha256 = "sha256-GNGS+Ec4Js7o9BLsxLiptFqYlZ7+p9gniglEFcy34gw=";
  };

  patches = [
    ./config-path.patch
  ];

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

      mkdir -p $out/bin $out/libexec/${pname}
      cp -r . "$out/libexec/${pname}"

      makeWrapper ${python3Packages.python.interpreter} $out/bin/${meta.mainProgram} \
        --prefix PYTHONPATH : "$PYTHONPATH" \
        --add-flags "$out/libexec/${pname}/convert.py"

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
