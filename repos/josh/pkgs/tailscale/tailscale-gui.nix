{
  tailscale-gui,
  fetchurl,
  nix-update-script,
  runCommand,
}:
tailscale-gui.overrideAttrs (
  finalAttrs: previousAttrs: {
    version = "1.104.7";

    src = fetchurl {
      url = "https://pkgs.tailscale.com/stable/Tailscale-${finalAttrs.version}-macos.pkg";
      hash = "sha256-Dsq2DgmNMfnL0zSGdHQpPcCJeBVGZdp1w/P+H4IV1uc=";
    };

    installPhase = ''
      runHook preInstall
      xar -xf $src
      cd Distribution.pkg
      pbzx -n Payload | cpio -i

      mkdir -p $out/Applications $out/bin
      cp -R Tailscale.app $out/Applications/
      ln -s "$out/Applications/Tailscale.app/Contents/MacOS/Tailscale" "$out/bin/tailscale"

      runHook postInstall
    '';

    passthru = (previousAttrs.passthru or { }) // {
      tests = {
        version = runCommand "test-tailscale-gui-version" { } ''
          grep -F "<string>${finalAttrs.version}</string>" ${finalAttrs.finalPackage}/Applications/Tailscale.app/Contents/Info.plist
          touch $out
        '';
      };
      updateScript = nix-update-script {
        extraArgs = [
          "--url"
          "https://github.com/tailscale/tailscale"
          "--version-regex"
          "v(\\d+\\.\\d+\\.\\d+)$"
          "--version=stable"
          "--use-github-releases"
          "--override-filename"
          "pkgs/tailscale/tailscale-gui.nix"
        ];
      };
    };
  }
)
