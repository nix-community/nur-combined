{
  lib,
  python3Packages,
  fetchFromGitHub,
  stdenv,
  systemd,
  pandoc,
  kmod,
  gnutar,
  util-linux,
  cpio,
  bash,
  coreutils,
  btrfs-progs,
  libseccomp,
  qemu,
  replaceVars,
  udevCheckHook,
  nix-update-script,

  # extra binaries to merge into mkosi subprocesses' PATHs
  extraDeps ? [ ],
}:
let
  # Nixpkgs overrides many systemd paths -- we need to undo that
  systemdForMkosi =
    (systemd.override {
      withRepart = true;
      withBootloader = true;
      withSysusers = true;
      withFirstboot = true;
      withEfi = true;
      withUkify = true;
      withKernelInstall = true;
    }).overrideAttrs
      (prevAttrs: {
        # Use the normal PATH instead of the nix store override
        postPatch = (prevAttrs.postPatch or "") + ''
          substituteInPlace src/basic/path-util.h \
            --replace-fail '"${placeholder "out"}/bin/"' \
                           '"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
        '';

        # Use the normal nologin path, not from the nix store
        mesonFlags = (prevAttrs.mesonFlags or [ ]) ++ [
          (lib.mesonOption "nologin-path" "/usr/sbin/nologin")
        ];
      });

  pythonWithPefile = python3Packages.python.withPackages (ps: [ ps.pefile ]);

  deps = [
    bash
    btrfs-progs
    coreutils
    cpio
    gnutar
    kmod
    qemu
    systemdForMkosi
    util-linux
  ]
  ++ extraDeps;
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mkosi-HEAD";
  version = "26-unstable-2026-08-22";
  pyproject = true;

  outputs = [
    "out"
    "man"
  ];

  src = fetchFromGitHub {
    owner = "systemd";
    repo = "mkosi";
    rev = "583dcb0e16bb74ecaa45edc3afaaddb1e7312307";
    hash = "sha256-OfEyXSBqvkiVje0ga78eVMxOtAx1Ixa0bhmHTO9X5vQ=";
  };

  patches = [
    (replaceVars ./mkosi-nix-wrapping.patch {
      UKIFY = "${systemdForMkosi}/lib/systemd/ukify";
      PYTHON_PEFILE = lib.getExe pythonWithPefile;
      NIX_PATH = toString (lib.makeBinPath deps);
      MKOSI_SANDBOX = null; # replaced in postPatch, once $out is known
      LIBC = "${stdenv.cc.libc}/lib/libc.so.6";
      LIBSECCOMP = "${libseccomp.lib}/lib/libseccomp.so.2";
      QEMU_FIRMWARE = "${qemu}/share/qemu/firmware";
    })
  ];

  # Need the $out reference, so substitute here
  postPatch = ''
    substituteInPlace mkosi/{run,__init__}.py \
      --replace-fail '@MKOSI_SANDBOX@' "$out/bin/mkosi-sandbox"
  '';

  nativeBuildInputs = [
    pandoc
    python3Packages.setuptools
    python3Packages.setuptools-scm
    python3Packages.wheel
    udevCheckHook
  ];

  dependencies = deps;

  postBuild = ''
    ./tools/make-man-page.sh
  '';

  checkInputs = [
    python3Packages.pytestCheckHook
  ];

  postInstall = ''
    mkdir -p $out/share/man/man1
    mv mkosi/resources/man/mkosi.1 $out/share/man/man1/
  '';

  # Workaround for https://github.com/NixOS/nixpkgs/issues/510068
  postFixup = ''
    rm -f "$out/bin/mkosi-sandbox" "$out/bin/.mkosi-sandbox-wrapped"
    cp "$out/${python3Packages.python.sitePackages}/mkosi/sandbox.py" "$out/bin/mkosi-sandbox"
    sed -i "1i#!${python3Packages.python.interpreter} -SI" "$out/bin/mkosi-sandbox"
    chmod +x "$out/bin/mkosi-sandbox"
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Build legacy-free OS images, built from git master";
    homepage = "https://github.com/systemd/mkosi";
    license = lib.licenses.lgpl21Only;
    mainProgram = "mkosi";
    platforms = lib.platforms.linux;
  };
})
