{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  kit = python3Packages.buildPythonApplication rec {
    pname = "cased-kit";
    version = "1.8.0";

    src = fetchFromGitHub {
      owner = "cased";
      repo = "kit";
      tag = "v${version}";
      hash = "sha256-dZLK7HErvy6bk/LNMBAvVsx2U/sBPJjMbhsMSJQ299Q=";
    };

    pyproject = true;

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      anthropic
      click
      fastapi
      google-genai
      mcp
      numpy
      openai
      pathspec
      python-hcl2
      redis
      tiktoken
      tree-sitter-language-pack
      typer
      uvicorn
    ];

    meta = {
      description = "The toolkit for codebase mapping, symbol extraction, and many kinds of code search";
      homepage = "https://github.com/cased/kit";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "kit";
      # FIXME: Broken on nixos-25.05
      broken = python3Packages.mcp.version == "1.6.0";
    };
  };
in
kit.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    kit = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

      tests = {
        help = runCommand "test-kit-help" { nativeBuildInputs = [ kit ]; } ''
          kit --help
          touch $out
        '';
      };
    };
  }
)
