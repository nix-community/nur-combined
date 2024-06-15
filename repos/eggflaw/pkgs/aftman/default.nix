{
  lib,
  fetchFromGitHub,
  rustPlatform, 
  pkg-config,
  openssl
}:
rustPlatform.buildRustPackage rec {
  pname = "aftman";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "LPGhatguy";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-WDcZcN455s4wH33Zu9MQRr/E3iHlSyVdOFEf7R74TXA=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  cargoHash = "sha256-Mgy5oNA5skIuefTgwrWH42kUMLsVpVb560feNAtGvNw="; 

  doCheck = false;

  meta = with lib; {
    description = "the prodigal sequel to Foreman";
    homepage = "https://github.com/LPGhatguy/aftman";
    license = licenses.mit;   
  };
}
