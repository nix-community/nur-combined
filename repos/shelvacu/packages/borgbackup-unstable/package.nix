{
  lib,
  stdenv,
  acl,
  e2fsprogs,
  fetchFromGitHub,
  libb2,
  lz4,
  openssh,
  openssl,
  python3,
  xxHash,
  zstd,
  installShellFiles,

  borgstore,
  borghash,
}:

let
  python = python3;
in
python.pkgs.buildPythonApplication rec {
  pname = "borgbackup";
  version = "2.0.0b19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "borgbackup";
    repo = "borg";
    tag = version;
    hash = "sha256-oCVf/FcWJ0vPQrZ3Chd2UrWzRRZK1KJr1XpXpQU+qZ4=";
  };

  patches = [ ./fix-s3.patch ];

  build-system = with python.pkgs; [
    cython
    setuptools-scm
    pkgconfig
  ];

  nativeBuildInputs = with python.pkgs; [
    # docs
    sphinxHook
    sphinxcontrib-jquery
    guzzle-sphinx-theme

    # shell completions
    installShellFiles
  ];

  sphinxBuilders = [
    "singlehtml"
    "man"
  ];

  buildInputs = [
    libb2
    lz4
    xxHash
    zstd
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ acl ];

  dependencies = with python.pkgs; [
    msgpack
    packaging
    platformdirs
    argon2-cffi
    borgstore
    borghash
    (if stdenv.hostPlatform.isLinux then pyfuse3 else llfuse)
  ];

  makeWrapperArgs = [ ''--prefix PATH ':' "${openssh}/bin"'' ];

  preInstallSphinx = ''
    # remove invalid outputs for manpages
    rm .sphinx/man/man/_static/jquery.js
    rm .sphinx/man/man/_static/_sphinx_javascript_frameworks_compat.js
    rmdir .sphinx/man/man/_static/
  '';

  postInstall = ''
    installShellCompletion --cmd borg \
      --bash scripts/shell_completions/bash/borg \
      --fish scripts/shell_completions/fish/borg.fish \
      --zsh scripts/shell_completions/zsh/_borg
  '';

  nativeCheckInputs = with python.pkgs; [
    e2fsprogs
    py
    pytest-benchmark
    pytest-xdist
    pytestCheckHook
  ];

  pytestFlagsArray = [
    "--benchmark-skip"
    "--pyargs"
    "borg.testsuite"
  ];

  doCheck = false;
  # disabledTests = [
  #   # fuse: device not found, try 'modprobe fuse' first
  #   "test_fuse"
  #   "test_fuse_allow_damaged_files"
  #   "test_fuse_mount_hardlinks"
  #   "test_fuse_mount_options"
  #   "test_fuse_versions_view"
  #   "test_migrate_lock_alive"
  #   "test_readonly_mount"
  #   # Error: Permission denied while trying to write to /var/{,tmp}
  #   "test_get_cache_dir"
  #   "test_get_keys_dir"
  #   "test_get_security_dir"
  #   "test_get_config_dir"
  # ];

  preCheck = ''
    export HOME=$TEMP
  '';

  outputs = [
    "out"
    "doc"
    "man"
  ];

  disabled = python.pythonOlder "3.9";

  meta = with lib; {
    changelog = "https://github.com/borgbackup/borg/blob/${src.rev}/docs/changes.rst";
    description = "Deduplicating archiver with compression and encryption";
    homepage = "https://www.borgbackup.org";
    license = licenses.bsd3;
    platforms = platforms.unix; # Darwin and FreeBSD mentioned on homepage
    mainProgram = "borg";
  };
}
