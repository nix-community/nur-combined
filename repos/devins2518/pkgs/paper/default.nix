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
    rev = "bf3594013f4805e289286980fc07a85d58a73cca";
    sha256 = "sha256-MFvDd1e5k2k86dtLOCvYD9qE6dkDgpCVDQ+x8Ksm+24=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "snui-0.1.0" = "1d2pvraj61n0a3p2xi21dq4kgf0sjiqxyhjzhqy0mcbg7f4nwhrq";
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
