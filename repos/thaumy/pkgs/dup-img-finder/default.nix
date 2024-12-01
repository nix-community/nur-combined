{ lib
, pkgs
, rustPlatform
, fetchFromGitHub
}:
let
  appBinName = "dup-img-finder";
  appVersion = "0.2.0";
  appComment = "Find duplicate images by similarity";

  src = fetchFromGitHub {
    owner = "Thaumy";
    repo = "dup-img-finder";
    rev = "48975af031628d22d628fff7a6f36925e8929286";
    hash = "sha256-Ox14MnKoWNYn9WoMM7pSrQhibl/VUoKytbS8PDEnxkk==";
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
    homepage = "https://github.com/Thaumy/dup-img-finder";
    license = lib.licenses.mit;
    maintainers = [ "thaumy" ];
    platforms = lib.platforms.linux;
  };
}
