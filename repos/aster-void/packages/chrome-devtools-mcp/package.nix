{
  writeShellApplication,
  nodejs,
}: let
  version = "0.8.1";
in
  # I want to rewrite it to not use npx, but at least it works for now
  writeShellApplication {
    name = "chrome-devtools-mcp";
    runtimeInputs = [nodejs];
    text = ''
      npx -y chrome-devtools-mcp@${version} "$@"
    '';
  }
