{
  lib,
  stdenv,
  fetchFromGitHub,
  gleam,
  beamPackages,
  zig,
  zig_0_13 ? null,
  p7zip,
  writeText,
  runCommand,
}:

let
  # Map Nix system to Burrito target config
  systemToBurrito = {
    "x86_64-darwin" = {
      target = "macos";
      os = "darwin";
      cpu = "x86_64";
    };
    "aarch64-darwin" = {
      target = "macos";
      os = "darwin";
      cpu = "aarch64";
    };
    "x86_64-linux" = {
      target = "linux";
      os = "linux";
      cpu = "x86_64";
    };
    "aarch64-linux" = {
      target = "linux";
      os = "linux";
      cpu = "aarch64";
    };
  };

  defaultTarget =
    systemToBurrito.${stdenv.system} or {
      target = "linux";
      os = "linux";
      cpu = "x86_64";
    };

  # MixGleam archive for bridging Gleam + Mix
  mixGleam = fetchFromGitHub {
    owner = "gleam-lang";
    repo = "mix_gleam";
    tag = "v0.6.2";
    hash = "sha256-m7fJvMxfGn+kQObZscmNLITLtv9yStUT2nKRKXqCzrs=";
  };

  # Create a fake ERTS tarball from the current Erlang package.
  # Burrito expects a tar.gz containing otp-<version>-<os>-<cpu>/
  # with erts-*, releases/, lib/, misc/, usr/, Install
  makeErtsPackage =
    {
      os,
      cpu,
      erlangPackage,
      ...
    }:
    let
      version = erlangPackage.version;
    in
    runCommand "otp-${version}-${os}-${cpu}.tar.gz" { } ''
      mkdir -p otp-${version}-${os}-${cpu}
      cd otp-${version}-${os}-${cpu}

      cp -r ${erlangPackage}/lib/erlang/erts* erts-${version}
      cp -r ${erlangPackage}/lib/erlang/releases releases
      cp -r ${erlangPackage}/lib/erlang/lib lib
      cp -r ${erlangPackage}/lib/erlang/misc misc
      cp -r ${erlangPackage}/lib/erlang/usr usr
      touch Install

      cd ..
      tar czf $out otp-${version}-${os}-${cpu}
    '';

in
lib.makeOverridable (
  {
    src,
    pname ? null,
    version ? null,
    # Override Erlang/Elixir toolchain
    erlangPackage ? beamPackages.erlang,
    rebar3Package ? beamPackages.rebar3,
    elixirPackage ? beamPackages.elixir,
    gleamPackage ? gleam,
    zigPackage ? (if zig_0_13 != null then zig_0_13 else zig),
    # Burrito target selection
    target ? defaultTarget.target, # "linux" | "macos" | "windows"
    targetCpu ? defaultTarget.cpu, # "x86_64" | "aarch64"
    nativeBuildInputs ? [ ],
    ...
  }@attrs:
  let
    # -------------------------------------------------------------------------
    # Resolve `src` argument: it may be a derivation (a gleam package built with
    # mkDerivation + gleamFetchDeps + gleamErlangHook) or a plain path.
    # If it's a derivation, try to extract its original source directory.
    # -------------------------------------------------------------------------
    isDrv = lib.isDerivation src;

    srcPath =
      if isDrv then
        # Prefer the original source captured in the derivation, fallback to the
        # derivation outPath (which will error later if it lacks gleam.toml)
        src.src or src.origSrc or src
      else
        src;

    srcPname = if isDrv && src ? pname then src.pname else null;
    srcVersion = if isDrv && src ? version then src.version else null;

    # Parse Gleam metadata from gleam.toml at evaluation time
    gleamToml = fromTOML (builtins.readFile (srcPath + "/gleam.toml"));

    # Manifest may not exist for projects with no deps; handle gracefully
    hasManifest = builtins.pathExists (srcPath + "/manifest.toml");
    manifestToml =
      if hasManifest then
        fromTOML (builtins.readFile (srcPath + "/manifest.toml"))
      else
        { packages = [ ]; };

    # Gleam app name (used for BEAM modules, e.g., "my_app")
    appName = gleamToml.name;

    # Nix package name – defaults to caller-provided pname, then the source
    # derivation's pname, then the Gleam app name
    finalPname =
      if pname != null then
        pname
      else if srcPname != null then
        srcPname
      else
        appName;
    finalVersion =
      if version != null then
        version
      else if srcVersion != null then
        srcVersion
      else
        gleamToml.version;

    currentTarget =
      let
        os =
          if target == "macos" then
            "darwin"
          else if target == "windows" then
            "windows"
          else
            "linux";
      in
      {
        inherit target os;
        cpu = targetCpu;
      };

    ertsPackage = makeErtsPackage (
      currentTarget
      // {
        erlangPackage = erlangPackage;
      }
    );

    mixDeps = import ../../packages/beam.nix { inherit beamPackages; };

    # Fetch Gleam dependencies via Hex (mirrors nix-gleam-burrito)
    gleamDeps = builtins.listToAttrs (
      map (pkg: {
        name = pkg.name;
        value = beamPackages.fetchHex {
          pkg = pkg.name;
          version = pkg.version;
          sha256 = pkg.outer_checksum;
        };
      }) (manifestToml.packages or [ ])
    );

    gleamDepsString = builtins.concatStringsSep "\n      " (
      builtins.attrValues (
        builtins.mapAttrs (name: path: ''{:${name}, path: "deps/${name}", override: true},'') gleamDeps
      )
    );

    mixDepsString = builtins.concatStringsSep "\n      " (
      builtins.attrValues (
        builtins.mapAttrs (name: drv: ''{:${name}, path: "deps/${name}", override: true},'') mixDeps
      )
    );

    # Elixir entry point that boots the Gleam main function
    # Gleam's main is <app>@@main:run(<app>)
    mixEntry = writeText "${appName}.ex" ''
      defmodule ${lib.strings.toUpper appName}.Application do
        use Application

        @impl true
        def start(_type, _args) do
          :${appName}.main()
          System.halt(0)
        end
      end
    '';

    mixConfig = writeText "mix.exs" ''
      defmodule ${lib.strings.toUpper appName}.MixProject do
        use Mix.Project

        def project do
          [
            app: :${appName},
            version: "${finalVersion}",
            elixir: "~> 1.18",
            start_permanent: Mix.env() == :prod,
            deps: deps(),
            releases: releases(),
            archives: [mix_gleam: "~> 0.6"],
            compilers: [:gleam | Mix.compilers()],
            erlc_paths: [
              "build/dev/erlang/${appName}/_gleam_artefacts",
              "lib",
            ],
            erlc_include_path: "build/dev/erlang/${appName}/include",
            prune_code_paths: false,
          ]
        end

        def releases do
          [
            ${appName}: [
              include_executables_for: [:unix, :windows],
              steps: [:assemble, &Burrito.wrap/1],
              burrito: [
                targets: [
                  ${currentTarget.target}: [
                    os: :${currentTarget.os},
                    cpu: :${currentTarget.cpu},
                    custom_erts: "${ertsPackage}"
                  ]
                ]
              ],
              applications: [
                inets: :permanent,
                ssl: :permanent
              ],
              debug: Mix.env() != :prod,
              no_clean: false
            ]
          ]
        end

        def application do
          [
            mod: {${lib.strings.toUpper appName}.Application, []},
            extra_applications: [:inets, :ssl]
          ]
        end

        defp deps do
          [
            ${gleamDepsString}
            ${mixDepsString}
          ]
        end
      end
    '';

    # Avoid deno rebuild issue in gleam if needed
    gleam' = gleamPackage.overrideAttrs {
      nativeCheckInputs = [ ];
      doCheck = false;
    };

    defaultNativeBuildInputs = [
      gleam'
      beamPackages.hex
      elixirPackage
      erlangPackage
      rebar3Package
      zigPackage
      p7zip
    ]
    ++ nativeBuildInputs;

    # Filter attrs to avoid passing mkDerivation-specific keys twice
    filteredAttrs = removeAttrs attrs [
      "src"
      "pname"
      "version"
      "erlangPackage"
      "rebar3Package"
      "elixirPackage"
      "gleamPackage"
      "zigPackage"
      "target"
      "targetCpu"
      "nativeBuildInputs"
    ];
  in
  stdenv.mkDerivation (
    filteredAttrs
    // {
      pname = finalPname;
      version = finalVersion;

      src = srcPath;

      nativeBuildInputs = defaultNativeBuildInputs;

      env = {
        MIX_ENV = "prod";
        HEX_OFFLINE = 1;
        LANG = "C.UTF-8";
        LC_ALL = "C.UTF-8";
        MIX_PATH = "${beamPackages.hex}/lib/erlang/lib/hex/ebin";
        MIX_REBAR3 = "${beamPackages.rebar3}/bin/rebar3";
        BURRITO_TARGET = target;
      };

      configurePhase = ''
        runHook preConfigure

        export HOME=$(mktemp -d)
        mkdir -p $HOME/.mix/archives
        export MIX_HOME=$HOME/.mix

        echo "Adding mix config..."
        cp ${mixConfig} mix.exs

        echo "Adding mix entry point..."
        mkdir -p lib
        cp ${mixEntry} lib/${appName}.ex

        echo "Installing mix_gleam..."
        tmpdir=$(mktemp -d)
        cp -r ${mixGleam}/* $tmpdir/
        cd $tmpdir
        mix do archive.build, archive.install --force
        cd -

        echo "Installing rebar3..."
        mix local.rebar rebar3 ${rebar3Package}/bin/rebar3 --force

        echo "Installing Gleam and Mix deps to deps/ (writable)..."
        mkdir -p deps

        ${builtins.concatStringsSep "\n" (
          builtins.attrValues (
            builtins.mapAttrs (name: path: ''
              cp -r ${path} deps/${name}
              chmod -R +w deps/${name}
            '') gleamDeps
          )
        )}

        ${builtins.concatStringsSep "\n" (
          builtins.attrValues (
            builtins.mapAttrs (name: drv: ''
              cp -r ${drv}/src deps/${name}
              chmod -R +w deps/${name}
            '') mixDeps
          )
        )}
        # mix_gleam expects deps to be present; let it verify
        mix gleam.deps.get || true

        runHook postConfigure
      '';

      buildPhase = ''
        runHook preBuild

        mix compile
        mix release

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin

        # burrito_out contains one binary per target (e.g., linux, macos)
        # Copy and rename to $out/bin/<appName> and also provide $out/bin/<pname> symlink if different
        if [ -d burrito_out ]; then
          for bin in burrito_out/*; do
            if [ -f "$bin" ]; then
              cp "$bin" "$out/bin/${appName}"
              chmod +x "$out/bin/${appName}"
              break
            fi
          done
        fi

        if [ ! -f "$out/bin/${appName}" ]; then
          echo "ERROR: burrito_out binary not found"
          ls -R burrito_out || true
          ls -R _build || true
          exit 1
        fi

        # Provide pname alias if it differs from appName (e.g., pname uses dashes)
        if [ "${finalPname}" != "${appName}" ]; then
          ln -sf "${appName}" "$out/bin/${finalPname}"
        fi

        runHook postInstall
      '';

      meta = (attrs.meta or { }) // {
        mainProgram = appName;
        platforms = lib.platforms.all;
        description =
          attrs.meta.description or "Gleam application bundled as standalone binary via Burrito";
      };

      # Preserve any user-provided pname/version already set above
      passthru = (attrs.passthru or { }) // {
        inherit appName;
      };
    }
  )
)
