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
    vendorHash = "sha256-38LeCRfuUZ/OrIpD4Cn9YPEkzWpfQvVCvCy/r5mJj0Q=";

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
