{ rustPlatform, fetchgit, pkg-config, luajit, lib, ... }:
rustPlatform.buildRustPackage rec {
  pname = "freshfetch";
  version = "0.1.2";

  src = fetchgit {
    url = "https://github.com/k4rakara/${pname}";
    rev = "v${version}";
    hash = "sha256-8aXHffv4hHheQZGbYLsIMBxrEHW1uxonnJiSfmrgFd8=";
  };

  cargoSha256 = "sha256-oPnbyl+BmXqFSraov8RVn55UH2kshDD24w/tLiR/AFw=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ luajit ];

  meta = with lib; {
    description = "A fresh take on neofetch. ";
    homepage = "https://github.com/k4rakara/${pname}/tree/${src.rev}";
    license = licenses.mit;
    maintainers = [ maintainers.vanilla ];
    platforms = [ "x86_64-linux" ];
  };
}
