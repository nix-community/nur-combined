{ lib, stdenv, rustPlatform, fetchFromGitLab, pkgs }:

let rpathLibs = with pkgs; [ fontconfig wayland ];
in rustPlatform.buildRustPackage rec {
  pname = "paper";
  version = "unstable-2021-07-26";

  buildInputs = rpathLibs;
  nativeBuildInputs = with pkgs; [ pkg-config ];

  src = fetchFromGitLab {
    owner = "snakedye";
    repo = pname;
    rev = "2adcf6469636cf3296a80e2a17af63de312119f1";
    sha256 = "sha256-EdiT7nkkhgURB46EWeXQnjmuzL9i1YMr80ZsJ2H7mFU=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "snui-0.1.0" = "sha256-+dse0rI18n4sls7xuEWhpaezN/l6j8xBZh4HkjHwFOY=";
    };
  };

  installPhase = ''
    runHook preInstall
    install -D ./target/x86_64-unknown-linux-gnu/release/paper $out/bin/paper
    patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/paper
    runHook postInstall
  '';

  dontPatchELF = true; # we already did it :)

  meta = with lib; {
    description = "A wallpaper daemon for Wayland compositors";
    homepage = "https://github.com/snakedye/paper";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ devins2518 ];
  };
}
