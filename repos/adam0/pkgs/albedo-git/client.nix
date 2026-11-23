{
  # keep-sorted start
  buildGoModule,
  lib,
  makeBinaryWrapper,
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
    # The albedo dispatcher execs these siblings from its own directory.
    subPackages = [
      # keep-sorted start
      "cmd/albedo"
      "cmd/albedo-acp"
      "cmd/albedo-server"
      "cmd/albedo-tui"
      "cmd/albedo-web"
      # keep-sorted end
    ];
    # Must match the vendored modules of the pinned Albedo revision.
    vendorHash = "sha256-/5RQfj2hLn6lHAF58O6vvOrIKpeCDywqc2ROCQ9oFBQ=";

    # keep-sorted start
    ALBEDO_NO_BROWSER = "1";
    ALBEDO_TEST_DAEMON = "${server}/bin/albedo-daemon";
    # keep-sorted end

    nativeBuildInputs = [
      # keep-sorted start
      makeBinaryWrapper
      python311
      # keep-sorted end
    ];

    meta.license = import ./license.nix {inherit lib;};

    postInstall =
      (import ./install-notices.nix {
        dependencyRoot = "vendor";
        pname = "albedo-client";
        inherit src;
      })
      + ''
        # Siblings stay together in libexec; the joined package owns the public
        # albedo-server command.
        mkdir -p $out/libexec
        mv $out/bin $out/libexec/albedo
        mkdir $out/bin
        for name in albedo albedo-{acp,tui,web}; do
          ln -s ../libexec/albedo/$name $out/bin/$name
        done
        wrapProgram $out/libexec/albedo/albedo-tui --inherit-argv0 --prefix PATH : ${makeBinPath clipboardTools}
      '';
  }
