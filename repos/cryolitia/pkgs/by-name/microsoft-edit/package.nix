{
  lib,
  stdenv,
  pkgs,
  fetchFromGitHub,
}:
let 
  
  hasRustNightly = pkgs ? rust-bin;

  rustPlatform = if hasRustNightly then
    pkgs.makeRustPlatform {
            cargo = pkgs.rust-bin.nightly.latest.minimal;
            rustc = pkgs.rust-bin.nightly.latest.minimal;
          }
  else
    pkgs.rustPlatform;
in 

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "microsoft-edit";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "edit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5GUAHa0/7k4uVNWEjn0hd1YvkRnUk6AdxTQhw5z95BY=";
  };

  cargoHash = "sha256-DEzjfrXSmum/GJdYanaRDKxG4+eNPWf5echLhStxcIg=";

  meta = with lib; {
    description = "MS-DOS style terminal editor";
    homepage = "https://github.com/microsoft/edit";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ Cryolitia ];
    mainProgram = "edit";
    broken = stdenv.isDarwin;
  };
})
