{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package =
      (pkgs.vscode.override {
        commandLineArgs = [
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
          "--gtk-version=4"
          "--enable-features=WaylandWindowDecorations"
          "--enable-wayland-ime"
          "--password-store=gnome-libsecret"
        ];
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
