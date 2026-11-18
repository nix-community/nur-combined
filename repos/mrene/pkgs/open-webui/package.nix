{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  fetchurl,
  buildNpmPackage,
  makeWrapper,
  python312,
}:
let
  version = "0.13.3";

  src = fetchFromGitHub {
    owner = "open-webui";
    repo = "open-webui";
    tag = "v${version}";
    hash = "sha256-cyMlCVgUd+zNsrmkL833lVjwfhF50IQsNjC1cWwu8bs=";
  };

  python = python312;

  # Backend for in-browser Python execution; must match package-lock.json.
  pyodideVersion = "314.0.3";
  pyodide = fetchurl {
    url = "https://github.com/pyodide/pyodide/releases/download/${pyodideVersion}/pyodide-${pyodideVersion}.tar.bz2";
    hash = "sha256-oCgELZDbqedP377PNuqn1X6IvwrWGNnFBZ6xBAqnYSo=";
  };
  lockedPyodide = (lib.importJSON "${src}/package-lock.json").packages."node_modules/pyodide".version;

  # PyPI's Linux torch wheels are CUDA builds pulling in gigabytes of nvidia-*
  # wheels. Swap in the CPU build of the version locked in uv.lock.
  torchCpu = {
    version = "2.12.1";
    wheels = {
      x86_64-linux = {
        platform = "manylinux_2_28_x86_64";
        hash = "sha256-rkuyhAn1NwhSvXGvIhBmI2w41kf3gNmwpyQMMwqcEt8=";
      };
      aarch64-linux = {
        platform = "manylinux_2_28_aarch64";
        hash = "sha256-0WILx7z4CH8+SIIbXbmUoD4y3bCD1YwAC44DL4puLRU=";
      };
    };
  };
  isCudaDist = name: lib.hasPrefix "nvidia-" name || lib.hasPrefix "cuda-" name || name == "triton";

  frontend = buildNpmPackage {
    pname = "open-webui-frontend";
    inherit version src;

    npmDepsHash = "sha256-uYXXyi6qN2269PLMQg6POqREdM1UCJc4cEzyGp6LkAQ=";
    npmFlags = [ "--force" ];

    # `pyodide:fetch` downloads wheels from PyPI during the build. Unpack the
    # pyodide distribution instead; in-browser Python then lacks the PyPI-only
    # extras that script adds (black, openpyxl, python-docx, ...).
    postPatch = ''
      substituteInPlace package.json \
        --replace-fail "npm run pyodide:fetch && " ""
    '';

    env = {
      CYPRESS_INSTALL_BINARY = "0";
      ONNXRUNTIME_NODE_INSTALL_CUDA = "skip";
    };

    preBuild = ''
      tar xf ${pyodide} -C static/
    '';

    installPhase = ''
      runHook preInstall
      cp -a build $out
      runHook postInstall
    '';
  };

  uv = callPackage ./uv2nix.nix { };
  workspace = uv.uv2nix.lib.workspace.loadWorkspace { workspaceRoot = "${src}"; };

  # sdist-only packages with a setup.py and no declared build system.
  setuptoolsSdists = [ "antlr4-python3-runtime" ];

  overrides =
    final: prev:
    lib.genAttrs setuptoolsSdists (
      name:
      prev.${name}.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ final.resolveBuildSystem { setuptools = [ ]; };
      })
    )
    // {
      torch = prev.torch.overrideAttrs (
        old:
        lib.optionalAttrs stdenv.hostPlatform.isLinux (
          let
            wheel = torchCpu.wheels.${stdenv.hostPlatform.system};
            pyTag = "cp${lib.replaceStrings [ "." ] [ "" ] python.pythonVersion}";
            file = "torch-${torchCpu.version}+cpu-${pyTag}-${pyTag}-${wheel.platform}.whl";
          in
          assert lib.assertMsg (
            old.version == torchCpu.version
          ) "open-webui: uv.lock pins torch ${old.version} but torchCpu is ${torchCpu.version}; update it";
          {
            src = fetchurl {
              name = file;
              url = "https://download.pytorch.org/whl/cpu/${lib.replaceStrings [ "+" ] [ "%2B" ] file}";
              inherit (wheel) hash;
            };
            passthru = old.passthru // {
              dependencies = lib.filterAttrs (name: _: !isCudaDist name) old.passthru.dependencies;
            };
          }
        )
      );

      # pyproject.nix ranks soundfile's `none-any` wheel equal to the manylinux
      # one and picks it, but only the manylinux wheel bundles libsndfile.
      soundfile = prev.soundfile.overrideAttrs (
        old:
        lib.optionalAttrs stdenv.hostPlatform.isLinux {
          src =
            let
              suffix = "-manylinux_2_28_${stdenv.hostPlatform.parsed.cpu.name}.whl";
              wheel = lib.findFirst (
                w: lib.hasSuffix suffix w.url
              ) (throw "open-webui: no soundfile wheel ending in ${suffix}") old.passthru.package.wheels;
            in
            fetchurl { inherit (wheel) url hash; };
        }
      );

      open-webui = prev.open-webui.overrideAttrs (old: {
        # hatch_build.py runs `npm install && npm run build`; ship the prebuilt
        # frontend through pyproject.toml's force-include of `build` instead.
        env = (old.env or { }) // {
          HATCH_BUILD_NO_HOOKS = "true";
        };
        preBuild = ''
          cp -r ${frontend} build
        '';

        meta = {
          description = "Comprehensive suite for LLMs with a user-friendly WebUI";
          homepage = "https://github.com/open-webui/open-webui";
          changelog = "https://github.com/open-webui/open-webui/blob/v${version}/CHANGELOG.md";
          # Modified BSD-3 with branding requirements; nixpkgs treats it as non-free.
          license = lib.licenses.mkLicense {
            shortName = "openWebUI";
            fullName = "Open WebUI License";
            url = "https://github.com/open-webui/open-webui/blob/v${version}/LICENSE";
            free = false;
          };
          maintainers = with lib.maintainers; [ mrene ];
          mainProgram = "open-webui";
          platforms = builtins.attrNames torchCpu.wheels;
        };
      });
    };

  pythonSet = (callPackage uv.pyproject-nix.build.packages { inherit python; }).overrideScope (
    lib.composeManyExtensions [
      uv.build-systems.overlays.wheel
      (workspace.mkPyprojectOverlay { sourcePreference = "wheel"; })
      overrides
    ]
  );

  venv = pythonSet.mkVirtualEnv "open-webui-env-${version}" workspace.deps.default;
  inherit (callPackage uv.pyproject-nix.build.util { }) mkApplication;
in
assert lib.assertMsg (lockedPyodide == pyodideVersion)
  "open-webui: package-lock.json pins pyodide ${lockedPyodide} but pyodideVersion is ${pyodideVersion}; update it";
(mkApplication {
  inherit venv version;
  pname = "open-webui";
  package = pythonSet.open-webui;
}).overrideAttrs
  (old: {
    # mkApplication takes `name` from the uv2nix package, which has no version.
    name = "open-webui-${version}";

    # DATA_DIR and STATIC_DIR default to directories inside site-packages,
    # which is read-only here. Explicit settings (e.g. the NixOS module) win.
    nativeBuildInputs = old.nativeBuildInputs ++ [ makeWrapper ];
    postInstall = ''
      wrapProgram $out/bin/open-webui \
        --run 'export DATA_DIR="''${DATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/open-webui}"' \
        --run 'export STATIC_DIR="''${STATIC_DIR:-$DATA_DIR/static}"'
    '';

    passthru = old.passthru // {
      inherit src frontend venv;
    };
  })
