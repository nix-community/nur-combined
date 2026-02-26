{
  autoPatchelfHook,
  dotnet-runtime,
  fetchurl,
  hash,
  icu,
  lib,
  makeWrapper,
  openssl,
  stdenv,
  url,
  version,
  zlib,
}:

let
  isAarch64 = stdenv.hostPlatform.isAarch64;

  # ARM64 patch releases from https://github.com/anegostudios/VintagestoryServerArm64
  # One release covers all patch versions within a major.minor version
  arm64Patches = {
    "1.21" = {
      url = "https://github.com/anegostudios/VintagestoryServerArm64/releases/download/1.21.0/vs_server_linux-arm64_1.21.0.tar.gz";
      hash = "sha256-oPJrOZlBBVnx+isPPCcDZ/9Z1aKJ2ZBBnV8+MdGvWdE=";
    };
    "1.20" = {
      url = "https://github.com/anegostudios/VintagestoryServerArm64/releases/download/1.20.0-rc.8/vs_server_linux-arm64_1.20.0.tar.gz";
      hash = "sha256-ZEH/hMSfR9tk7eRfxTXdOgFR/x3SJU3dpYGOB/zcj5M=";
    };
    "1.19" = {
      url = "https://github.com/anegostudios/VintagestoryServerArm64/releases/download/1.19.0-rc.6/vs_server_linux-arm64-1.19.tar.gz";
      hash = "sha256-FtokkWa2jIFgHd/oiDkh0C8xpE9xMqpWOvyTQ9MwcHI=";
    };
    "1.18" = {
      url = "https://github.com/anegostudios/VintagestoryServerArm64/releases/download/1.18.8/vs_server_linux-arm64-1.18.tar.gz";
      hash = "sha256-7ks6s6kj3utt8RxdujM90Ysn1nWjGWXKr9AI7Or3Wyc=";
    };
  };

  majorMinor = lib.versions.majorMinor version;
  arm64Patch = arm64Patches.${majorMinor} or null;
  arm64Src =
    if isAarch64 && arm64Patch != null then fetchurl { inherit (arm64Patch) url hash; } else null;
in

stdenv.mkDerivation {
  pname = "VintagestoryServer";
  inherit version;

  src = fetchurl {
    inherit url;
    sha256 = hash;
  };

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    icu
    openssl
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/VintagestoryServer

    # Extract the official x86_64 server tarball
    tar xzf $src -C $out/lib/VintagestoryServer

    ${lib.optionalString (isAarch64 && arm64Src != null) ''
      # Remove x86_64-specific files
      rm -f $out/lib/VintagestoryServer/VintagestoryServer
      rm -f $out/lib/VintagestoryServer/VintagestoryServer.dll
      rm -f $out/lib/VintagestoryServer/VintagestoryServer.deps.json
      rm -f $out/lib/VintagestoryServer/VintagestoryServer.pdb
      rm -f $out/lib/VintagestoryServer/VintagestoryServer.runtimeconfig.json
      rm -rf $out/lib/VintagestoryServer/Lib

      # Extract ARM64 replacement files
      tar xzf ${arm64Src} -C $out/lib/VintagestoryServer
    ''}

    # version 1.21+ should use dotnet-runtime_8
    # older versions should use dotnet-runtime_7
    makeWrapper ${dotnet-runtime}/bin/dotnet $out/bin/VintagestoryServer \
      --add-flags "$out/lib/VintagestoryServer/VintagestoryServer.dll"

    runHook postInstall
  '';

  passthru = {
    updateScript = ./update.py;
  };

  meta = with lib; {
    description = "Vintage Story Server";
    longDescription = ''
      Vintage Story is an uncompromising wilderness survival sandbox game inspired by eldritch horror themes. Find yourself in a ruined world reclaimed by nature and permeated by unnerving temporal disturbances. Relive the advent of human civilization, or take your own path.
    '';
    homepage = "https://vintagestory.at/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    platforms = [
      "x86_64-linux"
    ]
    ++ lib.optionals (versionAtLeast version "1.18.0") [ "aarch64-linux" ];
    maintainers = [ ];
    mainProgram = "VintagestoryServer";
  };
}
