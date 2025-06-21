### Wait for rustc-1.87 (master => nixos-unstable) (state here: https://nixpk.gs/pr-tracker.html?pr=407444)
{ pkgs, lib, stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "msedit";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "edit";
    rev = "v${version}";
    hash = "sha256-ubdZynQVwCYhZA/z4P/v6aX5rRG9BCcWKih/PzuPSeE=";
  };
  
  ### Use rust nightly from this variable
  env.RUSTC_BOOTSTRAP = 1;

  ### hash from cargo.lock to the edit repository
  cargoHash = "sha256-qT4u8LuKX/QbZojNDoK43cRnxXwMjvEwybeuZIK6DQQ=";
  
  ### Disable install check (found here: https://github.com/RossSmyth/nixpkgs/blob/4f09843cb4edf26fac02a021eecfd9e5af0e5206/pkgs/by-name/ms/ms-edit/package.nix)
  doInstallCheck = false;

  postInstall = ''
    ### Create doc directory
    mkdir -p $out/share/doc/${pname}

    ### Move files in this directory
    cp $src/LICENSE $out/share/doc/${pname}
    cp $src/README.md $out/share/doc/${pname}

    ### rename "edit" to "msedit"
    mv $out/bin/edit $out/bin/msedit
  '';
    
  meta = {
    description = "A simple editor for simple needs.";
    homepage = "https://github.com/microsoft/edit";
    license = lib.licenses.mit;
    mainProgram = "msedit";
  };
}
