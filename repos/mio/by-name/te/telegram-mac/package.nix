{
  lib,
  stdenvNoCC,
  python3,
  git,
  cacert,
  cmake,
  ninja,
  openssl,
  zlib,
  autoconf,
  libtool,
  automake,
  yasm,
  nasm,
  pkg-config,
  unzip,
}:

# NOTE: Building TelegramSwift (the native Telegram for macOS client) from source
# is notoriously complex in a pure Nix environment. It relies heavily on Xcode,
# Swift Package Manager (which requires network access during the build), and
# specific code-signing setups.
#
# This derivation provides a foundation, but achieving a fully pure, functional
# build will likely require:
# 1. Impure builds (sandbox = false) to allow Xcode and SPM network access.
# 2. Or, a complex translation of Swift Package Manager dependencies into Nix.
# 3. Supplying valid `api_id` and `api_hash` credentials.

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "telegram-mac";
  version = "10.14"; # Update to the latest desired version

  src = stdenvNoCC.mkDerivation {
    name = "telegram-mac-source";
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-hp1cI+6dbAWrgfgq5nNUScyDDe48E8k7GmaGWxyTCvM="; # Will need to be updated after first run
    
    nativeBuildInputs = [ git cacert ];
    
    buildCommand = ''
      export HOME=$(mktemp -d)
      git config --global url."https://github.com/".insteadOf "git@github.com:"
      git config --global url."https://gitlab.com/".insteadOf "git@gitlab.com:"
      
      git clone https://github.com/overtake/TelegramSwift.git $out
      cd $out
      git checkout 579cebbf0c01fd41b712eff3647fa7f69db9665d
      git submodule update --init --recursive
      rm -rf .git
    '';
  };

  nativeBuildInputs = [
    python3
    cmake
    ninja
    openssl
    zlib
    autoconf
    libtool
    automake
    yasm
    nasm
    pkg-config
    unzip
  ];

  # Using xcodebuild directly usually requires the environment to have Xcode available.
  # This requires setting `sandbox = false` in your nix.conf for Darwin.
  __noChroot = true; # Hint for Hydra/Nix to disable sandbox if possible
  dontUseCmakeConfigure = true;

  buildPhase = ''
    runHook preBuild

    # Allow scripts to find xcrun and xcodebuild on the host
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin

    # Telegram for macOS requires framework configuration first
    sed -i 's/no/yes/g' scripts/rebuild || true
    
    # Fix CMake 3.5 compatibility for Mozjpeg
    sed -i 's/cmake_minimum_required(VERSION .*/cmake_minimum_required(VERSION 3.5)/g' submodules/telegram-ios/third-party/mozjpeg/mozjpeg/CMakeLists.txt || true
    
    # Fix libwebp ZIP extraction (Nix GNU tar does not support ZIP, use unzip)
    sed -i 's/tar -xzf "$SOURCE_ARCHIVE" --directory "$OUT_DIR"/unzip -q "$SOURCE_ARCHIVE" -d "$OUT_DIR"/g' core-xprojects/libwebp/libwebp/build*.sh || true
    
    # Run the setup script
    sh scripts/configure_frameworks.sh

    # Build the app using xcodebuild
    xcodebuild -workspace Telegram-Mac.xcworkspace \
               -scheme Telegram \
               -configuration Release \
               -derivedDataPath build \
               CODE_SIGN_IDENTITY="" \
               CODE_SIGNING_REQUIRED=NO \
               CODE_SIGNING_ALLOWED=NO

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/Applications
    cp -r build/Build/Products/Release/Telegram.app $out/Applications/
    
    runHook postInstall
  '';

  meta = {
    description = "Telegram for macOS (Native Swift Client)";
    longDescription = ''
      The native macOS Telegram client, built from source. 
      Warning: Building this requires Xcode and is generally not pure.
    '';
    homepage = "https://github.com/overtake/TelegramSwift";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.darwin;
  };
})
