{
  curl,
  fetchFromGitHub,
  fetchurl,
  git,
  lib,
  nix,
  pkg-config,
  protobuf,
  python313,
  stdenv,
  which,
  writeShellApplication,
}:

let
  deps = import ./deps.nix {
    inherit
      lib
      stdenv
      fetchFromGitHub
      fetchurl
      pkg-config
      protobuf
      python313
      which
      ;
  };
  inherit (deps) python;
in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "codexctl";
  version = "1.2.1-unstable-2026-11-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Jayy001";
    repo = "codexctl";
    # Upstream release tags are Unix timestamps rather than semantic versions.
    tag = "1794370117";
    hash = "sha256-hIwaKIU7ER7bhVYzkPe16XIa5ycFWxFIXfA65yy4jK0=";
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

  passthru.updateScript = writeShellApplication {
    name = "update-codexctl";
    runtimeInputs = [
      curl
      git
      nix
      python313
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="codexctl"
      exec python3 ${./update.py} "$@"
    '';
  };

  meta = {
    description = "Automated update management for the reMarkable tablet";
    homepage = "https://github.com/Jayy001/codexctl";
    changelog = "https://github.com/Jayy001/codexctl/releases";
    license = lib.licenses.gpl3Only;
    mainProgram = "codexctl";
    platforms = lib.platforms.unix;
  };
})
