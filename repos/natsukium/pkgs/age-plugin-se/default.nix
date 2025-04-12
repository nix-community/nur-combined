{
  source,
  lib,
  swift,
  swiftpm,
  swiftpm2nix,
  swiftPackages,
}:
let
  generated = swiftpm2nix.helpers ./nix;
in

swiftPackages.stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname version src;

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  configurePhase = generated.configure;

  makeFlags = [ "RELEASE=1" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Age plugin for Apple's Secure Enclave";
    homepage = "https://github.com/remko/age-plugin-se";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
    mainProgram = "age-plugin-se";
    platforms = lib.platforms.all;
  };
})
