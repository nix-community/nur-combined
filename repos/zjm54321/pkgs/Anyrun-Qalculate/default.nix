{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage {
  pname = "anyrun-qalculate";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "udragg";
    repo = "anyrun-qalculate";
    rev = "main";
    hash = "sha256-FQ793hPKreCeV8YMSBmqKu0eQBcrA1fTx9wVC50NSdU="; 
  };

  cargoHash = "sha256-kTXbi8aAGh7S9ZJvnSW1+QvryAns1P6X0QRKFNjdI6M=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  doCheck = false;

  buildType = "release";
  cargoBuildFlags = [ "--lib" ];

  postInstall = ''
  mv $out/lib/libqalculate.so $out/lib/libanyrun_qalculate.so
  '';

  meta = with lib; {
    description = "Qalculate plugin for Anyrun launcher";
    homepage = "https://gitlab.com/udragg/anyrun-qalculate";
    license = licenses.gpl3Only;
    maintainers = [ "zjm54321" ];
    platforms = platforms.linux;
  };
}