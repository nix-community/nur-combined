{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package =
      (pkgs.vscode.override {
        commandLineArgs = "--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime -r";
      }).fhsWithPackages
        (
          ps: with ps; [
            rustup
            zlib
          ]
        );
    # userSettings = builtins.fromJSON (builtins.readFile ./settings.jsonc);
  };
}
