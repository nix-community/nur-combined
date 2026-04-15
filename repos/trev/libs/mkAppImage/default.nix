{
  lib,
  pkgsStatic,
  squashfsTools,
  stdenv,
  stdenvNoCC,
  writeClosure,
}:

{
  src ? null,
  pname ? src.pname or src.name,
  version ? src.version or "unstable",
  architecture ? src.stdenv.hostPlatform.go.GOARCH or stdenv.hostPlatform.go.GOARCH,
  name ? "${pname}-${version}-${architecture}.AppImage",

  squashfsArgs ? [
    "-b 1M"
    "-comp zstd"
    "-Xcompression-level 22"
  ],
}:

assert src != null;

let
  apprun = pkgsStatic.callPackage ../../packages/bwrap-apprun { };
  runtime = pkgsStatic.callPackage ../../packages/type2-runtime { };

  systemToCross =
    system:
    if
      system == "x86_64-linux"
      || system == "aarch64-linux"
      || system == "armv7l-linux"
      || system == "armv6l-linux"
    then
      if stdenv.hostPlatform.isStatic then system + "-musl" else system + "-gnu"
    else
      system;

  package =
    if
      (stdenv.hostPlatform.isStatic || (stdenv.hostPlatform.system != stdenv.buildPlatform.system))
    then
      (src.${systemToCross stdenv.hostPlatform.system} or src)
    else
      src;

  args = [
    "-offset $(stat -L -c%s ${lib.escapeShellArg (lib.getExe runtime)})" # squashfs comes after the runtime
    "-all-root" # chown to root
    "-no-recovery" # don't create a recovery file, since we won't be able to read it back anyway
  ]
  ++ squashfsArgs;

  platforms = [
    "x86_64-linux"
    "aarch64-linux"
    "armv7l-linux"
    "armv6l-linux"
  ];
in

stdenvNoCC.mkDerivation {
  inherit pname version;
  src = null; # we don't need any source files, since we'll be copying everything in the build phase

  nativeBuildInputs = [
    squashfsTools
  ];

  dontUnpack = true;

  configurePhase = ''
    if ! test -x ${lib.getExe package}; then
      echo "entrypoint '${lib.getExe package}' is not executable"
      exit 1
    fi
  '';

  buildPhase = ''
    build=$(mktemp -u)

    # finds extra files in derivation and copy to extras dir
    ${./extra-files.sh} ${package}

    # add the nix store closure and the entrypoint symlink
    mksquashfs ${
      builtins.concatStringsSep " " (
        [
          "$(cat ${writeClosure [ package ]})"
          "$build"
          "-p ${lib.escapeShellArg "entrypoint s 555 0 0 ${lib.getExe package}"}" # create symlink to the exe as the entrypoint
          "-no-strip" # don't strip leading dirs, to preserve the fact that everything's in the nix store
        ]
        ++ args
      )
    }

    # add the AppRun and extras
    mksquashfs ${
      builtins.concatStringsSep " " (
        [
          "${apprun}/bin/*" # add AppRun and its dependencies
          "$(find extras -mindepth 1 -maxdepth 1)" # add extra files from the extras dir
          "$build"
        ]
        ++ args
      )
    }

    # add the runtime to the start
    dd if=${lib.escapeShellArg (lib.getExe runtime)} of=$build conv=notrunc
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv $build $out/bin/${name}
    chmod 755 $out/bin/${name}
  '';

  meta = (package.meta or { }) // {
    mainProgram = name;
    platforms = builtins.filter (platform: builtins.elem platform platforms) (
      package.meta.platforms or platforms
    );
  };
}
