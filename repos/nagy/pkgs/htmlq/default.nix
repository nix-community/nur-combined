{ lib, stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "htmlq";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "mgdm";
    repo = "htmlq";
    rev = "v0.3.0";
    hash = "sha256-pTw+dsbbFwrPIxCimMsYfyAF2zVeudebxVtMQV1cJnE=";
  };

  cargoHash = "sha256-nMQqO5w4oqIKRad6tkBKzm5XHAONem7AJymAYVITdko=";

  meta = with lib; {
    description = "Like jq, but for HTML";
    homepage = "https://github.com/mgdm/htmlq";
    license = with licenses; [ mit ];
  };
}
