{
  # keep-sorted start
  buildGo126Module,
  fetchFromTangled,
  git,
  installShellFiles,
  lib,
  makeWrapper,
  openssh,
  python314Packages,
  stdenv,
  # keep-sorted end
}:
buildGo126Module (finalAttrs: {
  pname = "tg";
  version = "0.6.0-unstable-2026-10-03";

  src = fetchFromTangled {
    did = "did:plc:g5uweck3xar3m745g43giuhr";
    rev = "6b7c6e42584c451e392eed150b4f850b2d6438af";
    hash = "sha256-Jgq2N/2dIoIJ9kPOyIrjPvqFsBa4dDdBo5oL3nvTKug=";
  };

  vendorHash = "sha256-MdwyWIcirjkx4tljhvsx65aTBfYA/eyMmsGmvTZVAnQ=";
  proxyVendor = true;

  subPackages = ["cmd/tg"];

  nativeBuildInputs = [installShellFiles makeWrapper];
  nativeCheckInputs = [git];

  postPatch = ''
    sed -i -E 's/^([[:space:]]*)version = ("[^"]+")/\1versionPlaceholder = \2/' internal/cli/root.go
    printf '\nvar version = "${finalAttrs.version}"\n' >> internal/cli/root.go
  '';

  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  postInstall =
    ''
      makeWrapper ${finalAttrs.passthru.tgmcp}/bin/tgmcp $out/bin/tgmcp \
        --set-default TGMCP_EXECUTABLE $out/bin/tg \
        --prefix PATH : ${lib.makeBinPath [git openssh]}
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      manPageDir=$(mktemp -d)
      $out/bin/tg man "$manPageDir"
      installManPage "$manPageDir"/*

      installShellCompletion --cmd tg \
        --bash <($out/bin/tg completion bash) \
        --fish <($out/bin/tg completion fish) \
        --zsh <($out/bin/tg completion zsh)
    '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/alyraffauf/tg/internal/cli.version=${finalAttrs.version}"
  ];

  passthru.tgmcp = let
    pythonPackages = python314Packages.overrideScope (_final: prev:
      lib.optionalAttrs (python314Packages.py-key-value-aio.version == "0.3.0" && python314Packages.aws-sam-translator.disabled) {
        py-key-value-aio = prev.py-key-value-aio.overridePythonAttrs (old: {
          # Version 0.3.0's DynamoDB tests require aws-sam-translator via aioboto3.
          nativeCheckInputs = lib.filter (dep:
            !(lib.elem (lib.getName dep) ["aioboto3" "types-aiobotocore-dynamodb"]))
          old.nativeCheckInputs;
          disabledTestPaths = (old.disabledTestPaths or []) ++ ["tests/stores/dynamodb"];
        });
      });
  in
    pythonPackages.buildPythonApplication {
      pname = "tgmcp";
      inherit (finalAttrs) version src;
      sourceRoot = "source/mcp";
      pyproject = true;
      build-system = [pythonPackages.uv-build];
      dependencies = with pythonPackages; [fastmcp pydantic];
      pythonRemoveDeps = ["ruff" "ty"];
      pythonRelaxDeps = ["fastmcp" "pydantic"];
      postPatch = ''
        substituteInPlace pyproject.toml --replace-fail 'uv_build>=0.12.17,<0.13.0' 'uv_build'
        substituteInPlace tests/test_tools.py --replace-fail '.input_schema' '.inputSchema' --replace-fail '.output_schema' '.outputSchema' --replace-fail '.read_only_hint' '.readOnlyHint' --replace-fail '.idempotent_hint' '.idempotentHint' --replace-fail '.destructive_hint' '.destructiveHint'
      '';
      nativeCheckInputs = with pythonPackages; [pytestCheckHook pytest-asyncio];
      pythonImportsCheck = ["tgmcp"];
    };

  meta = {
    # keep-sorted start
    description = "Command-line client and MCP server for Tangled";
    homepage = "https://tangled.org/aly.codes/tg";
    license = lib.licenses.gpl3Plus;
    mainProgram = "tg";
    platforms = lib.platforms.unix;
    # keep-sorted end
  };
})
