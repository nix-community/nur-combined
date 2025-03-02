{
  runCommand,
  python3Packages,
  nur,
}:
let
  source = nur.repos.josh.mcp-servers-source;

  readabilipy' = python3Packages.readabilipy.overrideAttrs (
    _finalAttrs: previousAttrs: {
      disabledTests = previousAttrs.disabledTests ++ [ "test_have_node_5" ];
    }
  );

  mcp-server-fetch = python3Packages.buildPythonPackage rec {
    pname = "mcp-server-fetch";
    inherit (source) version;

    src = source;
    sourceRoot = "${source.name}/src/fetch";

    pyproject = true;
    __structuredAttrs = true;

    build-system = [ python3Packages.hatchling ];

    dependencies = [
      python3Packages.markdownify
      python3Packages.mcp
      python3Packages.protego
      readabilipy'
      python3Packages.requests
    ];

    meta = source.meta // {
      description = "A Model Context Protocol server providing tools to fetch and convert web content for usage by LLMs";
      homepage = "https://github.com/modelcontextprotocol/servers/tree/main/src/fetch";
      mainProgram = "mcp-server-fetch";
    };
  };
in
mcp-server-fetch.overrideAttrs (
  finalAttrs: _previousAttrs:
  let
    mcp-server-fetch = finalAttrs.finalPackage;
  in
  {
    passthru.tests = {
      help =
        runCommand "test-mcp-server-fetch-help"
          {
            __structuredAttrs = true;
            nativeBuildInputs = [ mcp-server-fetch ];
          }
          ''
            mcp-server-fetch --help
            touch $out
          '';
    };
  }
)
