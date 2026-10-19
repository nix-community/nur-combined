{
  lib,
  python3,
  fetchFromGitHub,
  fetchPypi,
  autoconf,
  automake,
  libtool,
}:

let
  inherit (python3.pkgs)
    buildPythonPackage
    buildPythonApplication
    pytestCheckHook
    setuptools
    uv-build
    z3-solver
    ;

  # Versions and the Shasta revision follow upstream's uv.lock.
  libdash = buildPythonPackage {
    pname = "libdash";
    version = "0.5.0";
    pyproject = true;
    src = fetchPypi {
      pname = "libdash";
      version = "0.5.0";
      hash = "sha256-MZQL4Tl/5enVNBTli+76gN1mKIKT7zxxqmjz/yYv6WQ=";
    };
    build-system = [ setuptools ];
    nativeBuildInputs = [
      autoconf
      automake
      libtool
    ];
    postPatch = ''
      # Nix provides libtoolize on Darwin too, not Homebrew's glibtoolize.
      substituteInPlace setup.py --replace-fail '"glibtoolize"' '"libtoolize"'
    '';
    # setup.py configures and builds the bundled C library itself.
    dontConfigure = true;
    env.CFLAGS = "-std=gnu17";
    pythonImportsCheck = [ "libdash" ];
  };

  pash-annotations = buildPythonPackage {
    pname = "pash-annotations";
    version = "0.2.4";
    format = "wheel";
    # Upstream publishes only a wheel for this release.
    src = fetchPypi {
      pname = "pash_annotations";
      version = "0.2.4";
      format = "wheel";
      python = "py3";
      dist = "py3";
      hash = "sha256-/0dab4EzOTM3t+HFpjloGeCDLB4mAcM0T5BcwsbUh9I=";
    };
    pythonImportsCheck = [ "pash_annotations" ];
  };

  shasta = buildPythonPackage {
    pname = "shasta";
    version = "0.5";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "binpash";
      repo = "shasta";
      rev = "3ec173d6dc96e9007f5b582634f9315eafcac867";
      hash = "sha256-royjA/t/KZLg8ouFWKyFCiuBKlMDlmBJ9nuXvGqZDbc=";
    };
    build-system = [ setuptools ];
    pythonImportsCheck = [ "shasta" ];
  };
in
buildPythonApplication {
  pname = "sash";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "atlas-brown";
    repo = "sash";
    rev = "v0.1.2";
    hash = "sha256-nEpI4ggkFUzGZ7m3ry0qIz8DyfHj+FRn1HmG/CUfhx0=";
  };

  build-system = [ uv-build ];
  # nixpkgs' Z3 bindings do not provide Python distribution metadata.
  pythonRemoveDeps = [ "z3-solver" ];
  dependencies = [
    libdash
    pash-annotations
    shasta
    z3-solver
  ];

  postPatch = ''
    # Allow the newer build backend supplied by nixpkgs.
    substituteInPlace pyproject.toml \
      --replace-fail 'uv_build>=0.8.15,<0.9.0' 'uv_build>=0.8.15' \
      --replace-fail 'shasta @ git+https://github.com/binpash/shasta' 'shasta==0.5'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  pythonImportsCheck = [
    "sash"
    "sash.main"
  ];

  meta = {
    description = "Static analysis of shell program effects using symbolic execution";
    homepage = "https://github.com/atlas-brown/sash";
    license = lib.licenses.mit;
    mainProgram = "sash";
    platforms = lib.platforms.unix;
  };
}
