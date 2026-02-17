{
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkgs,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "uv-build";
  version = "0.10.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = "sha256-sqCDBiSjZilFIf3qXKppQhxhnMQ9tQHv1fQNBCay/x4=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-xoSmGyzdtgGupZdNzxQU18GkCg+s1jiZPeMMnqnVsDk=";
  };

  buildAndTestSubdir = "crates/uv-build";

  # $src/.github/workflows/build-binaries.yml#L139
  maturinBuildProfile = "minimal-size";

  pythonImportsCheck = [ "uv_build" ];

  # The package has no tests
  doCheck = false;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--commit"
        "${finalAttrs.pname}"
      ];
    };
    python310 = pkgs.callPackage ./. {
      inherit (pkgs.python310Packages) buildPythonPackage;
    };
    python311 = pkgs.callPackage ./. {
      inherit (pkgs.python311Packages) buildPythonPackage;
    };
    python312 = pkgs.callPackage ./. {
      inherit (pkgs.python312Packages) buildPythonPackage;
    };
    python313 = pkgs.callPackage ./. {
      inherit (pkgs.python313Packages) buildPythonPackage;
    };
    python314 = pkgs.callPackage ./. {
      inherit (pkgs.python314Packages) buildPythonPackage;
    };
    python315 = pkgs.callPackage ./. {
      inherit (pkgs.python315Packages) buildPythonPackage;
    };
  };

  meta = {
    description = "Minimal build backend for uv";
    homepage = "https://docs.astral.sh/uv/reference/settings/#build-backend";
    inherit (pkgs.uv.meta) changelog license;
    platforms = lib.platforms.all;
  };
})
