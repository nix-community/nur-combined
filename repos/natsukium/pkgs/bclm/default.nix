{
  lib,
  stdenv,
  fetchFromGitHub,
  swift,
  swiftPackages,
  swiftpm,
  swiftpm2nix,
}:

let
  generated = swiftpm2nix.helpers ./nix;
in
swiftPackages.stdenv.mkDerivation rec {
  pname = "bclm";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "zackelia";
    repo = "bclm";
    rev = "refs/tags/v${version}";
    hash = "sha256-PLdbQZr4u5RCriyO9F7HaK95TupOMy9DLIjiqakRQEs=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  configurePhase = generated.configure;

  installPhase = ''
    runHook preInstall

    binPath="$(swiftpmBinPath)"
    install -Dm755 $binPath/bclm -t $out/bin

    runHook postInstall
  '';

  nativeCheckInputs = [ swiftPackages.XCTest ];

  # error: XCTest not available
  doCheck = false;

  meta = with lib; {
    description = "MacOS command-line utility to limit max battery charge";
    homepage = "https://github.com/zackelia/bclm";
    license = licenses.mit;
    maintainers = with maintainers; [ natsukium ];
    platforms = platforms.darwin;
    mainProgram = "bclm";
    # error: failed to build module 'Combine'
    # this SDK is not supported by the compiler (the SDK is built with 'Apple Swift version 5.3.1 (swiftlang-1200.2.41 clang-1200.0.32.8)'
    # while this compiler is 'Swift version 5.8 (swift-5.8-RELEASE)'). Please select a toolchain which matches the SDK.
    # disable until swift is fixed
    # https://github.com/NixOS/nixpkgs/issues/327836#issuecomment-2308417434
    broken = true;
  };
}
