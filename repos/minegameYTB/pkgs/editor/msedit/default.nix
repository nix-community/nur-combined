### Nix expression enhanced with @RossSmyth nix expr
{
  pkgs,
  lib, 
makeRustPlatform,
  patchelf,
  icu,
  fetchFromGitHub,
}:

let
  ### pin rust nightly with fenix project (fenix : https://github.com/nix-community/fenix)
  ### (based on https://github.com/dtomvan/nur-packages/blob/0d9b84b67786425c259ecdb83f7a88165f06395d/pkgs/microsoft-edit/package.nix#L14)
  fenixToolchain = import ../../buildSupport/rust-fenix/buildSupportNightly.nix { inherit pkgs; };
  rustPlatform = makeRustPlatform {
    inherit (fenixToolchain) cargo rustc;
  };
in

rustPlatform.buildRustPackage rec {
  pname = "msedit";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "edit";
    rev = "v${version}";
    hash = "sha256-Sb73awgdajBKKW0QIpmKF6g9mIIS/1f0a6D/jQulnUM=";
  };
  
  ### Use rust nightly from this variable
  env.RUSTC_BOOTSTRAP = 1;

  ### hash from cargo.lock to the edit repository
  cargoHash = "sha256-U8U70nzTmpY6r8J661EJ4CGjx6vWrGovu5m25dvz5sY=";
  
  ### Disable install check (found here: https://github.com/RossSmyth/nixpkgs/blob/4f09843cb4edf26fac02a021eecfd9e5af0e5206/pkgs/by-name/ms/ms-edit/package.nix)
  doInstallCheck = false;

  ### Build inputs
  nativeBuildInputs = [ patchelf ];

  postInstall = ''
    ### Create doc directory
    mkdir -p $out/share/doc/${pname}

    ### Move files in this directory
    cp $src/LICENSE $out/share/doc/${pname}
    cp $src/README.md $out/share/doc/${pname}

    ### rename "edit" to "msedit"
    mv $out/bin/edit $out/bin/msedit
  '';

  postFixup = ''
    ### Add icu ("Unicode and globalization support library") to the app environment (via patchelf)
    ### (based on https://github.com/dtomvan/nur-packages/blob/0d9b84b67786425c259ecdb83f7a88165f06395d/pkgs/microsoft-edit/package.nix)
    patchelf $out/bin/msedit \
      --add-rpath ${lib.makeLibraryPath [ icu ]}
  '';
    
  meta = {
    description = "A simple editor for simple needs.";
    homepage = "https://github.com/microsoft/edit";
    license = lib.licenses.mit;
    mainProgram = "msedit";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with lib.maintainers; [ minegameYTB ];
  };
}
