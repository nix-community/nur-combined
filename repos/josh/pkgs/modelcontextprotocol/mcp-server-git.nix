{
  runCommand,
  python3Packages,
  nur,
}:
let
  source = nur.repos.josh.mcp-servers-source;

  mcp-server-git = python3Packages.buildPythonPackage rec {
    pname = "mcp-server-git";
    inherit (source) version;

    src = source;
    sourceRoot = "${source.name}/src/git";

    pyproject = true;
    __structuredAttrs = true;

    build-system = [ python3Packages.hatchling ];

    dependencies = [
      python3Packages.click
      python3Packages.gitpython
      python3Packages.mcp
    ];

    meta = source.meta // {
      description = "A Model Context Protocol server providing tools to read, search, and manipulate Git repositories programmatically via LLMs";
      homepage = "https://github.com/modelcontextprotocol/servers/tree/main/src/git";
      mainProgram = "mcp-server-git";
    };
  };
in
mcp-server-git.overrideAttrs (
  finalAttrs: _previousAttrs:
  let
    mcp-server-git = finalAttrs.finalPackage;
  in
  {
    passthru.tests = {
      help =
        runCommand "test-mcp-server-git-help"
          {
            __structuredAttrs = true;
            nativeBuildInputs = [ mcp-server-git ];
          }
          ''
            mcp-server-git --help
            touch $out
          '';
    };
  }
)
