with import <nixpkgs> { };
{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule {
  pname = "misspell";
  version = "v0.4.1";

  src = fetchFromGitHub {
    owner = "golangci";
    repo = "misspell";
    rev = "v0.4.1";
    hash = "sha256-J9M0sCLz3J1XJWq6dP+n1nkMbaQyNBlqS7tSY1WsCAk=";
  };

  vendorHash = "sha256-qf787Dg6Xy3HGkgroATQ+Xd15muLpkVDuzFskBktEXo=";

  doCheck = false;

  meta = with lib; {
    description = "Correct commonly misspelled English words in source files";
    homepage = "https://github.com/golangci/misspell";
    changelog = "https://github.com/golangci/misspell/commits";
    maintainers = with maintainers; [ caarlos0 ];
    mainProgram = "misspell";
  };
}
