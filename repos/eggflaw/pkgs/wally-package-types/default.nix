{
  lib,
  fetchFromGitHub,
  rustPlatform, 
}:
rustPlatform.buildRustPackage rec {
  pname = "wally-package-types";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "JohnnyMorganz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-KKEv8y1U1M1MmN3+/Brfe35IYsQtBUyf8D8r9zfSyEM=";
  };

  cargoHash = "sha256-o6Gpm02PmgwgVwuv5yLlqpIoMCO/KKWnYGgOYT/9iAw="; 

  meta = with lib; {
    description = "Re-export types in Wally package thunks";
    homepage = "https://github.com/JohnnyMorganz/wally-package-types";
    license = licenses.mit;   
  };
}
