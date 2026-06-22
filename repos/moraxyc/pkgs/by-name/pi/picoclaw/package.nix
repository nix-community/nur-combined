{
  callPackage,
  nixpkgs,

  sources,
  source ? sources.picoclaw,
}:
nixpkgs.picoclaw.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) version src;

    # nix-update auto
    vendorHash = "sha256-dVXjMzn2ClQJRTuhdpDNHvbzKuHThtfjZ4xiBz56I8E=";

    __darwinAllowLocalNetworking = true;

    preConfigure = ''
      rm -rf web/backend/dist
      cp -r ${finalAttrs.passthru.frontend} web/backend/dist
    '';

    postInstall = ''
      ln -sf $out/bin/{backend,picoclaw-launcher}
      install -Dm644 web/picoclaw-launcher.png -t $out/share/icons/hicolor/256x256/apps
      install -Dm444 web/picoclaw-launcher.desktop -t $out/share/applications
    '';

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
      # nix-update auto -sfrontend
      frontend = callPackage ./frontend.nix { picoclaw = finalAttrs; };
    };
  }
)
