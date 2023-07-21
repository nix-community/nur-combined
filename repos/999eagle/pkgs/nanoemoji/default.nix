{
  lib,
  python3,
  fetchFromGitHub,
  resvg,
  pngquant,
  callPackage,
}: let
  ninja = callPackage ./ninja.nix {};
  picosvg = callPackage ./picosvg.nix {};
in
  python3.pkgs.buildPythonApplication rec {
    pname = "nanoemoji";
    version = "0.15.1";

    src = fetchFromGitHub {
      owner = "googlefonts";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-P/lT0PnjTdYzyttICzszu4OL5kj+X8GHZ8doL3tpXQM=";
    };
    patches = [
      # this is necessary because the tests call nanoemoji, which calls ninja, which needs to import the nanoemoji python modules
      ./test-pythonpath.patch
      ./test.patch
    ];

    nativeBuildInputs = with python3.pkgs; [
      setuptools-scm
      resvg
      pngquant
      pythonRelaxDepsHook
    ];

    pythonRemoveDeps = ["resvg-cli" "pngquant-cli"];

    propagatedBuildInputs = with python3.pkgs; [
      absl-py
      fonttools
      lxml
      pillow
      regex
      tomlkit
      ufo2ft
      ufoLib2
      zopfli
      toml

      ninja
      picosvg
    ];

    nativeCheckInputs = with python3.pkgs; [
      pytestCheckHook
      pytest
      ninja
      picosvg
    ];

    makeWrapperArgs = [
      "--prefix PATH : ${lib.makeBinPath [resvg pngquant]}"
    ];

    preCheck = ''
      # make sure the built binaries can be found by the test
      export PATH="$out/bin:''${PATH}"
    '';
  }
