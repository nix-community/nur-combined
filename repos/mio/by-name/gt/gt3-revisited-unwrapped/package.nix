{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  sdl3,
  zlib,
  nix-update-script,
  writeShellApplication,
}:

let
  version = "0.8.0";

  # cmake/Dependencies.cmake fetches libchdr from git at configure time; the
  # sandbox has no network, so it gets this pinned source tree instead.
  libchdr = fetchFromGitHub {
    owner = "rtissera";
    repo = "libchdr";
    tag = "v0.3.0";
    hash = "sha256-jBk3Kd4q3HO3i2SxS0mBpQ80Vfm8vj1PQMXouK6Y/+k=";
  };
in
stdenv.mkDerivation {
  pname = "gt3-revisited";
  inherit version;

  src = fetchFromGitHub {
    owner = "matt-pulsipher";
    repo = "GT3-revisited";
    tag = "v${version}";
    hash = "sha256-J2ruhlWGnBT+cBFv60EeiyE7QapR9ZLA3EfIZ62NnO0=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    sdl3
    zlib
  ];

  # The .app's icon is rendered with sips and iconutil, and the bundle is
  # sealed with codesign: macOS tools the Nix build sandbox does not expose.
  # The bundle is installed without an icon, and Nix's fixup signs the
  # executable after patching it.
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace cmake/Packaging.cmake \
      --replace-fail 'target_sources(gt3r PRIVATE ''${_icns})' '# no .icns: sips is not available in the Nix build' \
      --replace-fail 'MACOSX_BUNDLE_ICON_FILE gt3r.icns' ""
  '';

  cmakeFlags = [
    "-DGT3R_BUILD_TESTS=OFF"
    "-DGT3R_BUILD_TOOLS=OFF"
    "-DFETCHCONTENT_SOURCE_DIR_LIBCHDR=${libchdr}"
  ];

  # The game reads the disc image at run time; nothing from it is built in.
  installPhase = ''
    runHook preInstall
  ''
  + (
    if stdenv.hostPlatform.isDarwin then
      ''
        app=$(find . -maxdepth 3 -type d -name 'gt3r.app' -print -quit)
        if [ -z "$app" ]; then
          echo "gt3-revisited: no gt3r.app in the build tree ($PWD)" >&2
          exit 1
        fi
        mkdir -p $out/Applications $out/bin
        cp -R "$app" "$out/Applications/GT3 Revisited.app"
        ln -s "../Applications/GT3 Revisited.app/Contents/MacOS/gt3r" $out/bin/gt3r
      ''
    else
      ''
        cmake --install . --prefix $out
      ''
  );

  passthru.updateScript = writeShellApplication {
    name = "update-gt3-revisited-unwrapped";
    text = ''
      export UPDATE_NIX_ATTR_PATH="gt3-revisited-unwrapped"
      exec ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [
            "--version-regex"
            "v(.*)"
          ];
        })
      } "$@"
    '';
  };

  meta = {
    description = "Open reimplementation of the Gran Turismo 3 A-Spec engine (needs your own disc)";
    longDescription = ''
      GT3 Revisited reimplements the Gran Turismo 3 A-Spec engine for modern
      platforms. It contains no game data: the disc image you made from your
      own copy is read at run time (`gt3r /path/to/image.iso`).
    '';
    homepage = "https://github.com/matt-pulsipher/GT3-revisited";
    license = lib.licenses.mit;
    mainProgram = "gt3r";
    # Upstream's macOS package is Apple silicon; Windows and mobile are built
    # by its own release scripts.
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
