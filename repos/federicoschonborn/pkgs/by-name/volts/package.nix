{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  postgresql,
  versionCheckHook,
}:

rustPlatform.buildRustPackage {
  pname = "volts";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "lapce";
    repo = "lapce-volts";
    rev = "6f9abb899480233f19d95ed9cdbc3600e6290c6e";
    hash = "sha256-yj/dEb2XEdQou8+8oPOa9LZj0C0grpvX/15S9aC4oJs=";
  };

  cargoHash = "sha256-ntmo+gFIgB10YEgNjpiv56EAlzzO11hEQ7eL9HW94Cc=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    postgresql
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;

  meta = {
    mainProgram = "volts";
    description = "CLI tool for publishing and managing Lapce plugins";
    homepage = "https://github.com/lapce/lapce-volts";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
