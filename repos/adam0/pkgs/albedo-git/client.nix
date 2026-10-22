{
  # keep-sorted start
  buildGoModule,
  lib,
  makeWrapper,
  python311,
  server,
  src,
  stdenv,
  wl-clipboard,
  xclip,
  # keep-sorted end
}: let
  inherit
    (lib)
    # keep-sorted start
    makeBinPath
    optionals
    # keep-sorted end
    ;

  clipboardTools = optionals stdenv.hostPlatform.isLinux [
    # keep-sorted start
    wl-clipboard
    xclip
    # keep-sorted end
  ];
in
  buildGoModule {
    pname = "albedo-client";
    version = "1.0.0";

    inherit src;

    modRoot = "cli";
    subPackages = ["cmd/albedo"];
    # Must match the vendored modules of the pinned Albedo revision.
    vendorHash = "sha256-JvLCRiPAIcDr1QfJvJufciGokbi5Wo8koxsxAc9wlvw=";

    # keep-sorted start
    ALBEDO_NO_BROWSER = "1";
    ALBEDO_TEST_DAEMON = "${server}/bin/albedo-daemon";
    # keep-sorted end

    nativeBuildInputs = [
      # keep-sorted start
      makeWrapper
      python311
      # keep-sorted end
    ];

    postInstall = ''
      wrapProgram $out/bin/albedo --prefix PATH : ${makeBinPath clipboardTools}
    '';
  }
