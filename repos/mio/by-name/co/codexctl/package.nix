{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  protobuf,
  python313,
  which,
}:

let
  # libfuse 2.x was dropped from nixpkgs (EOL upstream), but fuse-python -- and
  # therefore `codexctl mount` -- is tied to the 2.x ABI. Build the last 2.x
  # release locally so the mount subcommand works.
  libfuse2 = stdenv.mkDerivation (finalAttrs: {
    pname = "libfuse";
    version = "2.9.9";

    # The git tree needs autoreconf; the release tarball ships ./configure.
    src = fetchurl {
      url = "https://github.com/libfuse/libfuse/releases/download/fuse-${finalAttrs.version}/fuse-${finalAttrs.version}.tar.gz";
      hash = "sha256-0OadXWCMwi/0hDeRrQl/VU3TJUDdyb7XY4zG/qfBtLU=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      pkg-config
      which
    ];

    enableParallelBuilding = true;

    configureFlags = [ "--disable-example" ];

    # configure hardcodes /sbin, /etc/udev and /etc/init.d unless these are set.
    preConfigure = ''
      export MOUNT_FUSE_PATH=$out/sbin
      export UDEV_RULES_PATH=$out/lib/udev/rules.d
      export INIT_D_PATH=$out/etc/init.d
    '';

    NIX_CFLAGS_COMPILE = "-D_FILE_OFFSET_BITS=64";

    # glibc >= 2.34 declares closefrom() in <unistd.h>, clashing with the
    # helper's own static definition of the same name.
    postPatch = ''
      substituteInPlace util/ulockmgr_server.c \
        --replace-fail 'static int closefrom(int minfd)' 'static int fuse_closefrom(int minfd)' \
        --replace-fail 'closefrom(5);' 'fuse_closefrom(5);'
    '';

    postInstall = ''
      rm -f $out/lib/libfuse.la $out/lib/libulockmgr.la
    '';

    meta = {
      description = "Userspace filesystem framework (legacy 2.x series)";
      homepage = "https://github.com/libfuse/libfuse";
      license = with lib.licenses; [
        gpl2Only
        lgpl21Only
      ];
      pkgConfigModules = [ "fuse" ];
      platforms = lib.platforms.linux;
    };
  });

  # codexctl and its dependencies are the only consumers, so the packages that
  # are missing from nixpkgs are defined alongside it.
  python = python313.override {
    packageOverrides = pyfinal: _pyprev: {
      fuse-python = pyfinal.buildPythonPackage (finalAttrs: {
        pname = "fuse-python";
        version = "1.0.9";
        format = "setuptools";

        src = fetchFromGitHub {
          owner = "libfuse";
          repo = "python-fuse";
          tag = "v${finalAttrs.version}";
          hash = "sha256-qQum0roVQ4JYSkns5wK5nr6h3BPG4JUjS4rwRJwY7nM=";
        };

        # fuse-python links against the libfuse 2.x C API.
        buildInputs = [ libfuse2 ];
        nativeBuildInputs = [ pkg-config ];

        # Tests mount a FUSE filesystem, which the build sandbox forbids.
        doCheck = false;

        pythonImportsCheck = [ "fuse" ];

        meta = {
          description = "Python bindings for the libfuse 2.x API";
          homepage = "https://github.com/libfuse/python-fuse";
          license = lib.licenses.lgpl21Only;
          platforms = lib.platforms.linux;
        };
      });

      libconf = pyfinal.buildPythonPackage (finalAttrs: {
        pname = "libconf";
        version = "2.0.1";
        format = "setuptools";

        src = fetchFromGitHub {
          owner = "Grk0";
          repo = "python-libconf";
          tag = finalAttrs.version;
          hash = "sha256-pcacR2EZSqAKKLmxddgmHQGPH/p/KvrskoAB85r9C0o=";
        };

        nativeCheckInputs = [ pyfinal.pytestCheckHook ];

        pythonImportsCheck = [ "libconf" ];

        meta = {
          description = "Pure-Python libconfig reader/writer";
          homepage = "https://github.com/Grk0/python-libconf";
          license = lib.licenses.mit;
        };
      });

      ext4 = pyfinal.buildPythonPackage (finalAttrs: {
        pname = "ext4";
        version = "1.4.1";
        pyproject = true;

        src = fetchFromGitHub {
          owner = "Eeems";
          repo = "python-ext4";
          tag = "v${finalAttrs.version}";
          hash = "sha256-keE6o8SLCleU0CWzCdegAxtSheyO+Zl386fGdImVrq8=";
        };

        # Upstream builds with Nuitka through a custom backend; the package
        # is plain Python, so build it with setuptools instead.
        build-system = [ pyfinal.setuptools ];

        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail 'requires = ["setuptools >= 77.0.3", "nuitka>=4.0.6"]' 'requires = ["setuptools"]' \
            --replace-fail 'build-backend = "nuitka.distutils.Build"' 'build-backend = "setuptools.build_meta"'
        '';

        dependencies = with pyfinal; [
          cachetools
          crcmod
        ];

        nativeBuildInputs = [ pyfinal.pythonRelaxDepsHook ];

        # Upstream pins exact versions; nixpkgs tracks newer patch releases.
        pythonRelaxDeps = [ "cachetools" ];

        # Tests require ext4 images and loop devices.
        doCheck = false;

        pythonImportsCheck = [ "ext4" ];

        meta = {
          description = "Read-only interactions with an ext4 filesystem";
          homepage = "https://github.com/Eeems/python-ext4";
          license = lib.licenses.mit;
          platforms = lib.platforms.all;
        };
      });

      remarkable-update-image = pyfinal.buildPythonPackage (finalAttrs: {
        pname = "remarkable_update_image";
        version = "1.4.2";
        pyproject = true;

        src = fetchFromGitHub {
          owner = "Eeems";
          repo = "remarkable-update-image";
          tag = finalAttrs.version;
          hash = "sha256-3QFy9hnDcY6wNDc6pVO7jM6z7xDNnLcCWdLc9jCPDAk=";
        };

        build-system = [ pyfinal.setuptools ];

        dependencies = with pyfinal; [
          cachetools
          cryptography
          ext4
          indexed-gzip
          libconf
          protobuf
        ];

        # nixpkgs' protobuf exposes no pythonPath, so neither the metadata
        # check nor pythonImportsCheck can resolve it without an explicit path.
        env.PYTHONPATH = "${pyfinal.protobuf}/${pyfinal.python.sitePackages}";

        nativeBuildInputs = [ pyfinal.pythonRelaxDepsHook ];

        pythonRelaxDeps = [
          "cachetools"
          "cryptography"
          "ext4"
          "indexed-gzip"
          "libconf"
          "protobuf"
        ];

        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail 'requires = ["setuptools >= 77.0.3", "nuitka>=4.0.6"]' 'requires = ["setuptools"]' \
            --replace-fail 'build-backend = "nuitka.distutils.Build"' 'build-backend = "setuptools.build_meta"'
          # update_metadata_pb2.py is generated by the upstream Makefile and
          # is not checked in; generate it with the matching protoc.
          ${protobuf}/bin/protoc -I protobuf --python_out=remarkable_update_image protobuf/update_metadata.proto
        '';

        # Tests download firmware images and require loop devices.
        doCheck = false;

        pythonImportsCheck = [ "remarkable_update_image" ];

        meta = {
          description = "Read reMarkable update images";
          homepage = "https://github.com/Eeems/remarkable-update-image";
          license = lib.licenses.mit;
          platforms = lib.platforms.all;
        };
      });

      remarkable-update-fuse = pyfinal.buildPythonPackage (finalAttrs: {
        pname = "remarkable_update_fuse";
        version = "1.4.2";
        pyproject = true;

        src = fetchFromGitHub {
          owner = "Eeems-Org";
          repo = "remarkable-update-fuse";
          tag = finalAttrs.version;
          hash = "sha256-VsqNnNMiMW+7t1ltPrgXIptaut4Bg1o57HlF0sC3HCU=";
        };

        build-system = [ pyfinal.setuptools ];

        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail 'requires = ["setuptools>=77.1", "wheel", "nuitka"]' 'requires = ["setuptools"]' \
            --replace-fail 'build-backend = "nuitka.distutils.Build"' 'build-backend = "setuptools.build_meta"'
        '';

        dependencies = with pyfinal; [
          fuse-python
          remarkable-update-image
        ];

        nativeBuildInputs = [ pyfinal.pythonRelaxDepsHook ];

        pythonRelaxDeps = [
          "fuse-python"
          "remarkable-update-image"
        ];

        # Tests mount a FUSE filesystem, which the build sandbox forbids.
        doCheck = false;

        # Imports remarkable_update_image, which needs protobuf on sys.path
        # (nixpkgs' protobuf exposes no pythonPath).
        env.PYTHONPATH = "${pyfinal.protobuf}/${pyfinal.python.sitePackages}";

        pythonImportsCheck = [ "remarkable_update_fuse" ];

        meta = {
          description = "Userspace filesystem for reMarkable update files";
          homepage = "https://github.com/Eeems-Org/remarkable-update-fuse";
          license = lib.licenses.mit;
          platforms = lib.platforms.linux;
        };
      });
    };
  };

in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "codexctl";
  version = "1.2.1-unstable-2026-10-31";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Jayy001";
    repo = "codexctl";
    # Upstream tags are Unix timestamps rather than semantic versions.
    rev = "10e91e2675608ca999ebc7e056005b858304bf53";
    hash = "sha256-6PfZGIWThSulPMkPEyQuCGUVGfQpJQSLb2M2uLJ7xXk=";
  };

  build-system = [ python.pkgs.poetry-core ];

  # Mounting needs the FUSE filesystem; other platforms use the image reader.
  dependencies =
    with python.pkgs;
    [
      loguru
      paramiko
      psutil
      remarkable-update-image
      requests
    ]
    ++ lib.optional stdenv.hostPlatform.isLinux remarkable-update-fuse;

  # The test suite downloads multi-gigabyte firmware images from reMarkable.
  doCheck = false;

  nativeBuildInputs = [ python.pkgs.pythonRelaxDepsHook ];

  # Upstream pins exact versions; nixpkgs tracks newer releases.
  pythonRelaxDeps = [
    "loguru"
    "paramiko"
    "psutil"
    "remarkable-update-fuse"
    "remarkable-update-image"
    "requests"
  ];

  # nixpkgs' protobuf exposes no pythonPath, so the generated wrapper leaves
  # google.protobuf off sys.path even though remarkable_update_image needs it.
  makeWrapperArgs = [
    "--prefix"
    "PYTHONPATH"
    ":"
    "${python.pkgs.protobuf}/${python.sitePackages}"
  ];

  pythonImportsCheck = [ "codexctl" ];

  meta = {
    description = "Automated update management for the reMarkable tablet";
    homepage = "https://github.com/Jayy001/codexctl";
    changelog = "https://github.com/Jayy001/codexctl/releases";
    license = lib.licenses.gpl3Only;
    mainProgram = "codexctl";
    platforms = lib.platforms.unix;
  };
})
