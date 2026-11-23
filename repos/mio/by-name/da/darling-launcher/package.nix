{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6,
  libplist,
  python3,
  nix-update-script,
  coreutils,
  polkit,
  util-linux,
  git,
  fuse3,
}:

# The launcher validates the root-run mount helpers and their Python
# interpreter by walking every path component and rejecting anything in a
# group-writable directory. /nix/store is group-writable, so on NixOS the
# privileged mount actions stay disabled by design; the rest of the launcher
# (importing app bundles, launching prefixes, building a private VibeDarling
# runtime) works normally.
stdenv.mkDerivation (finalAttrs: {
  pname = "darling-launcher";
  version = "0.1-unstable-2026-11-13";

  src = fetchFromGitHub {
    owner = "cristim";
    repo = "darling-launcher";
    rev = "b8ac8d9e11bdeda6079d05a500b06bbbe6e9dac9";
    hash = "sha256-30EZ96xj1k7aVqjxybyeIREIlLIakq+UXKj16RQclms=";
  };

  # Upstream uses /usr/bin/stat to validate the ownership of every component
  # of the root-run helper path, which does not exist on NixOS.
  postPatch = ''
        substituteInPlace cmake/SelectPython.cmake \
          --replace-warn 'set(LAUNCHER_STAT_TOOL "/usr/bin/stat")' \
                         'set(LAUNCHER_STAT_TOOL "${coreutils}/bin/stat")'

        # Upstream installs only the mount helpers and leaves the launcher itself
        # in the build tree.
        cat >> CMakeLists.txt <<'EOF'

    install(TARGETS darling-launcher RUNTIME DESTINATION ''${CMAKE_INSTALL_BINDIR})
    EOF
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtimageformats
    libplist
  ];

  strictDeps = true;

  # The suite exercises the privileged paths through a root-owned Python and
  # root-owned helpers that are not writable by group or others. The Nix store
  # is group-writable, so those candidates are rejected by design and the
  # mount/builder tests cannot run here (they also need /usr/bin/git, zstd and
  # apfs-fuse). The remaining tests are covered by upstream CI; verify the
  # packaged GUI manually instead.
  doCheck = false;

  # The launcher shells out to these at runtime: git/cmake/ninja/python3 build
  # a private runtime, while pkexec/util-linux/fuse3 serve the mount helpers.
  qtWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        cmake
        fuse3
        git
        ninja
        polkit
        python3
        util-linux
      ]
    }"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=unstable" ];
  };

  meta = {
    description = "Qt launcher for isolated Darling prefixes and private macOS app imports";
    homepage = "https://github.com/cristim/darling-launcher";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "darling-launcher";
  };
})
