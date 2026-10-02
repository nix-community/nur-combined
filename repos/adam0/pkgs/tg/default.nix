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
  version = "0.6.0-unstable-2026-09-30";

  src = fetchFromTangled {
    did = "did:plc:g5uweck3xar3m745g43giuhr";
    rev = "7f97612adf0db53188a06e7f14f47461d54476e0";
    hash = "sha256-j66ps4380HopeTXrua9VjNDEVTsH+mtpcyfBO41O7Hs=";
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

  passthru.tgmcp = python314Packages.buildPythonApplication {
    pname = "tgmcp";
    inherit (finalAttrs) version src;
    sourceRoot = "source/mcp";
    pyproject = true;
    build-system = [python314Packages.uv-build];
    dependencies = with python314Packages; [fastmcp pydantic];
    pythonRemoveDeps = ["ruff" "ty"];
    pythonRelaxDeps = ["fastmcp" "pydantic"];
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail 'uv_build>=0.12.17,<0.13.0' 'uv_build'
      substituteInPlace tests/test_tools.py --replace-fail '.input_schema' '.inputSchema' --replace-fail '.output_schema' '.outputSchema' --replace-fail '.read_only_hint' '.readOnlyHint' --replace-fail '.idempotent_hint' '.idempotentHint' --replace-fail '.destructive_hint' '.destructiveHint'
    '';
    nativeCheckInputs = with python314Packages; [pytestCheckHook pytest-asyncio];
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
