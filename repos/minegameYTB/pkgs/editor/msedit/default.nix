### Nix expression enhanced with the help of @dtomvan and @RossSmyth on github with thier nix expressions
{
  pkgs,
  lib, 
  makeRustPlatform,
  icu,
  makeWrapper,
  fetchFromGitHub
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
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "edit";
    rev = "v${version}";
    hash = "sha256-G5U5ervW1NAQY/fnwOWv1FNuKcP+HYcAW5w87XHqgA8=";
  };
  
  ### Use rust nightly from this variable
  env.RUSTC_BOOTSTRAP = 1;

  ### hash from cargo.lock to the edit repository
  cargoHash = "sha256-ceAaaR+N03Dq2MHYel4sHDbbYUOr/ZrtwqJwhaUbC2o=";
  
  ### Disable install check (found here: https://github.com/RossSmyth/nixpkgs/blob/4f09843cb4edf26fac02a021eecfd9e5af0e5206/pkgs/by-name/ms/ms-edit/package.nix)
  doInstallCheck = false;

  ### Build inputs
  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    ### Create doc directory
    mkdir -p $out/share/doc/${pname}

    ### Move files in this directory
    cp $src/LICENSE $out/share/doc/${pname}
    cp $src/README.md $out/share/doc/${pname}

    ### rename "edit" to "msedit"
    mv $out/bin/edit $out/bin/msedit
    
    ### Add icu ("Unicode and globalization support library") to the app environment
    ### (based on https://github.com/dtomvan/nur-packages/blob/0d9b84b67786425c259ecdb83f7a88165f06395d/pkgs/microsoft-edit/package.nix)
    wrapProgram $out/bin/msedit \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ icu ]}
  '';
    
  meta = {
    description = "A simple editor for simple needs.";
    homepage = "https://github.com/microsoft/edit";
    license = lib.licenses.mit;
    mainProgram = "msedit";
  };
}
