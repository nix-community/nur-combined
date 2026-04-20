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
  name ?
    if lib.strings.hasInfix "-" pname then
      "${pname}_${version}_${architecture}.AppImage"
    else
      "${pname}-${version}-${architecture}.AppImage",

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

  # Try to use cross-compilation version of the package if it exists
  package = src.${stdenv.hostPlatform.config} or src;

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
  src = null;

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
    runHook preBuild

    # finds extra files in derivation and copy to extras dir
    ${./extra-files.sh} ${package}

    image=$(mktemp -u)

    # add the nix store closure and the entrypoint symlink
    mksquashfs ${
      builtins.concatStringsSep " " (
        [
          "$(cat ${writeClosure [ package ]})"
          "$image"
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
          "$image"
        ]
        ++ args
      )
    }

    # add the runtime to the start
    dd if=${lib.escapeShellArg (lib.getExe runtime)} of=$image conv=notrunc

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv $image $out/bin/${name}
    chmod +x $out/bin/${name}

    runHook postInstall
  '';

  meta = (package.meta or { }) // {
    mainProgram = name;
    platforms = builtins.filter (platform: builtins.elem platform platforms) (
      package.meta.platforms or platforms
    );
  };
}
