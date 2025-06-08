# adaptation of https://github.com/NixOS/nixpkgs/pull/409075 that works with
# nixos-unstable through fenix
# Credit @RossSmyth
{
  pkgs,
  lib,
  makeRustPlatform,
  fetchFromGitHub,
  unstableGitUpdater,
  makeWrapper,
  icu,
}:
# cursed to avoid flakes/npins/whatever
let
  fenix = fetchFromGitHub {
    owner = "nix-community";
    repo = "fenix";
    rev = "9be40ad995bac282160ff374a47eed67c74f9c2a"; # June 2025
    hash = "sha256-MJNhEBsAbxRp/53qsXv6/eaWkGS8zMGX9LuCz1BLeck=";
  };
  toolchain = (import fenix { inherit pkgs; }).minimal;
  rustPlatform = makeRustPlatform {
    inherit (toolchain) cargo rustc;
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "microsoft-edit";
  version = "1.1.0-unstable-2025-06-05";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "edit";
    rev = "5c5471e9443353b0f60c5380e515c4559e0316b1";
    hash = "sha256-dute8vMDR5MCZ8NVpkzMbm29+KLQIGEsNH4Eblqblr4=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Y+IVt3ZghoY+o/SHF/bW/wif5cqBljtqRWwURVw9DC4=";

  # dtomvan 2025-06-05:
  # I am not interested I want this NOW
  doCheck = false;

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    wrapProgram $out/bin/edit \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ icu ]}
  '';

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
  };

  meta = {
    description = "Simple editor for simple needs";
    longDescription = ''
      This editor pays homage to the classic MS-DOS Editor,
      but with a modern interface and input controls similar to VS Code.
      The goal is to provide an accessible editor that even users largely
      unfamiliar with terminals can easily use.
    '';
    mainProgram = "edit";
    homepage = "https://github.com/microsoft/edit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RossSmyth ];
  };
})
