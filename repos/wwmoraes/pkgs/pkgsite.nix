{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "pkgsite";
  version = "0.0.0+${rev}";
  rev = "557c002897fca2516fc696a6a39fa978ff5a719a";

  src = fetchFromGitHub {
    inherit rev;
    owner = "golang";
    repo = "pkgsite";
    hash = "sha256-RM1I5FeM8ZHn2AmSx5kUD/IqyTi4Up6Ab/j1FJ+ZfYU=";
  };

  vendorHash = "sha256-/+w3a+xOr4QrqTg7MSJlDh7XTeAPafqHtlAeSdNKqv8=";

  subPackages = [
    "cmd/pkgsite"
  ];

  meta = with lib; {
    description = "a site for discovering Go packages";
    homepage = "https://cs.opensource.google/go/x/pkgsite";
    license = licenses.bsd3;
    mainProgram = "pkgsite";
    maintainers = with maintainers; [ wwmoraes ];
    platforms = platforms.all;
  };
}
