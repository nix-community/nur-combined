{
  description = "Nix flake template for Scala projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    sbt-derivation = {
      url = "github:zaninime/sbt-derivation";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    sbt-derivation,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };

      name = "nix-flake-template";
      mainClass = "hello";

      app = sbt-derivation.lib.mkSbtDerivation {
        inherit pkgs;

        pname = name;
        version = "unstable";

        src = ./.;

        depsSha256 = "sha256-rVxXnlgRDcwZeOzGFxBheRRN2WtMHdyhGpIp8Oiwr6o=";

        depsWarmupCommand = ''
          sbt 'managedClasspath; compilers'
        '';

        startScript = ''
          #!${pkgs.runtimeShell}

          exec ${pkgs.openjdk_headless}/bin/java ''${JAVA_OPTS:-} -cp "${
            placeholder "out"
          }/share/${name}/lib/*" ${nixpkgs.lib.escapeShellArg mainClass} "$@"
        '';

        buildPhase = ''
          sbt stage
        '';

        installPhase = ''
          libs_dir="$out/share/${name}/lib"
          mkdir -p "$libs_dir"
          cp -ar target/universal/stage/lib/. "$libs_dir"

          install -T -D -m755 $startScriptPath $out/bin/${name}
        '';

        passAsFile = ["startScript"];
      };
    in {
      packages.default = app;

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [bashInteractive sbt];
        shellHook = "export PS1='\\e[1;34mdev > \\e[0m'";
      };
    });
}
