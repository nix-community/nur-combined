{ lib
, clang16Stdenv
, fetchFromGitHub
, cmake
, ninja
, pkg-config
, llvmPackages_16
, SDL2
, dbus
, openssl
, zlib
, unstableGitUpdater

, forceSystemBoost ? true
, boost
}:

clang16Stdenv.mkDerivation {
  pname = "vita3k";
  version = "unstable-2023-11-02";

  src = fetchFromGitHub {
    owner = "Vita3K";
    repo = "Vita3K";
    rev = "fb24695b9f8223c6352d5eea522459a1450c969d";
    hash = "sha256-PWCq8KK+WuJ7vL9rSYnbWANpw6FmkAXrCqitcZlMKsU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    llvmPackages_16.lld
    ninja
    pkg-config
  ];

  buildInputs = [
    SDL2
    dbus
    openssl
    zlib
  ] ++ lib.optional forceSystemBoost (boost.override { enableStatic = true; });

  dontFixCmake = true;

  cmakeFlags = [
    "--preset linux-ninja-clang"
    (lib.cmakeBool "VITA3K_FORCE_SYSTEM_BOOST" forceSystemBoost)
    (lib.cmakeBool "USE_DISCORD_RICH_PRESENCE" false)
    (lib.cmakeBool "USE_VITA3K_UPDATE" false)
  ];

  ninjaFlags = [
    "-C linux-ninja-clang"
  ];

  installPhase = ''
    runHook preInstall

    pushd linux-ninja-clang
      mkdir -p $out/{bin,share/vita3k}
      mv bin/Vita3K $out/bin/vita3k
      cp -r bin/* $out/share/vita3k
    popd

    cp data/image/icon.png $out/share/icons/hicolor/128x128/apps/vita3k.png

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    mainProgram = "Vita3K";
    description = "Experimental PlayStation Vita emulator";
    homepage = "https://vita3k.org/";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
