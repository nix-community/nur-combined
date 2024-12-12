{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeBinaryWrapper,
  sqlite,
}:

rustPlatform.buildRustPackage rec {
  pname = "pr-dashboard";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "FliegendeWurst";
    repo = "pr-dashboard";
    rev = "7020d1fcd21994bd44bcc04c79c4810678915dee";
    hash = "sha256-chHjMyvA13Pr8yoMjiem6spUX7JXJj6c2iFtug9hkos=";
  };

  cargoHash = "sha256-3zePZHKqWf+8THI4OIb9qkE+9BVM+6fzM85KwZY5X8w=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    makeBinaryWrapper
  ];
  buildInputs = [ sqlite ];

  postInstall = ''
    wrapProgram $out/bin/pr-dashboard \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ sqlite ]}"
  '';

  doInstallCheck = false;
  doCheck = false;

  meta = with lib; {
    description = "PR dashboard for nixpkgs";
    homepage = "https://github.com/FliegendeWurst/pr-dashboard";
    license = with licenses; [ gpl3Plus ];
    maintainers = with maintainers; [ fliegendewurst ];
    mainProgram = "pr-dashboard";
  };
}
