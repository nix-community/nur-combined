{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  openvino,
  openvino-genai,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
buildGoModule (finalAttrs: {
  pname = "ollama-openvino";
  version = "2026.4-unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "openvinotoolkit";
    repo = "openvino_contrib";
    rev = "9b77af15efc82af9626e47356ca385a5fab1c9f0"; # releases/2026/4
    hash = "sha256-g7c5vWWx1O+VLp6lclESIMisu/nzA7EKEGe1O8ijmBI=";
  };

  sourceRoot = "${finalAttrs.src.name}/modules/ollama_openvino";

  vendorHash = "sha256-ON9ow9/KglBy+RKNhw1n3E5AJtpjPQvJwNAQTaWzEFA=";

  postPatch = ''
    # Newer GCC no longer includes <cstdint> transitively.
    sed -i '1i #include <cstdint>' llama/llama.cpp/src/llama-mmap.h

    # OpenVINO GenAI fixed the spelling of its streaming status enum.
    substituteInPlace genai/genai.go \
      --replace-fail OV_GENAI_STREAMMING_STATUS OV_GENAI_STREAMING_STATUS
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    openvino
    openvino-genai
  ];

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/ollama/ollama/version.Version=${finalAttrs.version}"
    "-X=github.com/ollama/ollama/server.mode=release"
  ];

  # The GenAI bindings pass Go pointers to C callbacks.
  postFixup = ''
    wrapProgram $out/bin/ollama --set-default GODEBUG cgocheck=0
  '';

  # Tests need network access and a running server.
  doCheck = false;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = "HOME";
  doInstallCheck = true;

  passthru.updateScript = [
    ./update.sh
    "releases/${lib.versions.major openvino.version}/${lib.versions.minor openvino.version}"
  ];

  meta = {
    description = "Ollama with an OpenVINO GenAI backend for Intel CPUs, GPUs and NPUs";
    homepage = "https://github.com/openvinotoolkit/openvino_contrib/tree/master/modules/ollama_openvino";
    license = lib.licenses.mit;
    mainProgram = "ollama";
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
  };
})
