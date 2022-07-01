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
    rev = "fc91d5e0963f41d57df97076681a03804b57a5e1";
    sha256 = "sha256-JYFCapKp/kONGCrUBePi21t8C1bsYQz1FZDuA50tmOE=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "snui-0.1.0" = "sha256-QIDSaqJTJsBlyXHLuekUpHel8pYnp+CHhulcQvp7d8k=";
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
