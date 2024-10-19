{ buildGoModule, fetchgit, lib }:

buildGoModule {
	pname = "pkgsite";
	version = "0.0.0+557c002897fca2516fc696a6a39fa978ff5a719a";

	src = fetchgit {
		url = "https://go.googlesource.com/pkgsite";
		rev = "557c002897fca2516fc696a6a39fa978ff5a719a";
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
		platforms = platforms.all;
		maintainers = with maintainers; [ wwmoraes ];
	};
}
