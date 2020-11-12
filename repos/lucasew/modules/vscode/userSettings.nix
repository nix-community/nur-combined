let
  pkgs = import <nixpkgs> {};
in
{
  "workbench.iconTheme" = "file-icons";
  "workbench.colorTheme" = "One Dark Pro";
  "[typescriptreact]" = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
  "[jsonc]" = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
  "[typescript]" = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
  "rest-client.enableTelemetry" = false;
  "rust-client.disableRustup" = true;
  "go.useLanguageServer" = true;
}
