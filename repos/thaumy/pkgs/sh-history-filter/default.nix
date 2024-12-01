{ lib
, pkgs
, rustPlatform
, fetchFromGitHub
}:
let
  appBinName = "sh-history-filter";
  appVersion = "0.0.4";
  appComment = "Filter your shell history";

  src = fetchFromGitHub {
    owner = "Thaumy";
    repo = "sh-history-filter";
    rev = "8200dea3d43801eb1ec2b62227eab9e535515d68";
    sha256 = "sha256-hueHjhY1e6he6p2Lah8/eMb8JO5I58t69HZFBPnjWW4=";
  };

  toolchain = (pkgs.extend (import ../rust-overlay)).rust-bin.nightly."2024-11-20".minimal;

  buildTimeDeps = [
    toolchain
  ];
in
rustPlatform.buildRustPackage {
  pname = appBinName;
  version = appVersion;

  nativeBuildInputs = buildTimeDeps;

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  buildPhase = ''
    cp -r ${src}/* .
    cargo build -r
  '';

  installPhase = ''
    # bin
    mkdir -p $out/bin
    cp target/release/${appBinName} $out/bin

    # echo for debug
    echo -e "\nApp was successfully installed in $out\n"
  '';

  meta = {
    description = appComment;
    homepage = "https://github.com/Thaumy/sh-history-filter";
    license = lib.licenses.mit;
    maintainers = [ "thaumy" ];
    platforms = lib.platforms.linux;
  };
}
