{
  fetchFromGitHub,
  lib,
  nix-update-script,

  ghidra,
  makeWrapper,
  python3Packages,
  symlinkJoin,
}:
let
  version = "7.1.0-unstable-2026-11-25";

  src = fetchFromGitHub {
    owner = "bethington";
    repo = "ghidra-mcp";
    rev = "5ffd19e06d81a408edcde4a01661a03518f0bca8";
    fetchSubmodules = false;
    sha256 = "sha256-MHT5dint26U24ujH5aKCF/tY+j/TOQgdzZHpQjp7izU=";
  };
in
symlinkJoin {
  pname = "ghidra-mcp";
  inherit version src;
  paths = [
    (python3Packages.buildPythonApplication {
      pname = "ghidra-mcp-bridge";
      inherit version src;

      pyproject = true;

      build-system = with python3Packages; [ hatchling ];

      dependencies = [
        (
          (python3Packages.mcp.overrideAttrs (
            _:
            let
              version = "1.29.0";
            in
            {
              inherit version;
              src = fetchFromGitHub {
                owner = "modelcontextprotocol";
                repo = "python-sdk";
                rev = "v${version}";
                hash = "sha256-lRlj5RT/R5zrYL5XpdQR2l9t99G94WTsubN0gSQekMc=";
              };
            }
          )).overridePythonAttrs
            (_: {
              dependencies = with python3Packages; [
                httpx-sse
                jsonschema
                pydantic-settings
                pyjwt
                python-multipart
                sse-starlette
                starlette
                uvicorn
              ];
              dontUsePytestCheck = true;
            })
        )
      ];
    })

    (ghidra.buildGhidraExtension {
      pname = "ghidra-mcp-unwrapped";
      inherit version src;

      nativeBuildInputs = [ makeWrapper ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/{lib/Ghidra/Extensions,bin}
        unzip -d $out/lib/Ghidra/Extensions build/distributions/*.zip

        runHook postInstall
      '';
    })
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Production-ready Model Context Protocol (MCP) server that bridges Ghidra's powerful reverse engineering capabilities with modern AI tools and automation frameworks";
    homepage = "https://github.com/bethington/ghidra-mcp";
    license = lib.licenses.asl20;
    inherit (ghidra.meta) platforms;
    mainProgram = "bridge-mcp-ghidra";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
