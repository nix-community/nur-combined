{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  writeText,
  runCommand,
  nix-update-script,
}:
let
  defuddle = buildNpmPackage {
    pname = "defuddle";
    version = "0.6.4";

    src = fetchFromGitHub {
      owner = "kepano";
      repo = "defuddle-cli";
      tag = "0.6.0";
      hash = "sha256-XU/7ka4EWeLLQNrD6w2EpgQBPjo7wIO/JjWboIF6lzM=";
    };

    npmDepsHash = "sha256-pd8o35CI4G6XTam19A4Bw38VK5xeprIVZH+qaJUWbYU=";

    meta = {
      description = "Command line utility to extract clean html, markdown and metadata from web pages";
      homepage = "https://github.com/kepano/defuddle-cli";
      license = lib.licenses.mit;
      mainProgram = "defuddle";
    };
  };
in
defuddle.overrideAttrs (
  finalAttrs: _previousAttrs:
  let
    defuddle = finalAttrs.finalPackage;
    articleHtmlFile = writeText "article.html" ''
      <html>
        <head>
          <title>The Title</title>
        </head>
        <body>
          <h1>The Heading</h1>
          <p>The Content</p>
        </body>
      </html>
    '';
  in
  {
    passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

    passthru.tests = {
      help = runCommand "test-defuddle-help" { nativeBuildInputs = [ defuddle ]; } ''
        defuddle --help
        touch $out
      '';

      parse = runCommand "test-defuddle-parse" { nativeBuildInputs = [ defuddle ]; } ''
        title=$(defuddle parse ${articleHtmlFile} --property title)
        if [ "$title" != "The Title" ]; then
          echo "was '$title' expected 'The Title'"
          exit 1
        fi
        touch $out
      '';
    };
  }
)
