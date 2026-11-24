{
	pkg-config,
	perl, # openssl-sys build dep
	openssl,
	fetchFromGitHub,
	rustPlatform,
	nixosTests,
}:

rustPlatform.buildRustPackage rec {
	pname = "ruroco";
	version = "0.14.2";
	cargoHash = "sha256-TmgW149mQnb6rn0/qOn4c62GrtyJTTtvmfAjqT0Es7Q=";

	src = fetchFromGitHub {
		owner = "beac0n";
		repo = "ruroco";
		rev = "v" + version;
		hash = "sha256-wUgta9s390dXyW59/ybIL0WEStKWrsP4Tw+ITdkRSfw=";
	};

	nativeBuildInputs = [ pkg-config perl ];
	buildInputs = [ openssl ];

	# ./commander.patch 
	# patches = [ ./cargofeatures2.patch ./noupdate.patch ];

	# by default, build features are configured for server so services.ruroco will work automatically
	# to install any combination of client, gui, or server, modify the build features using
	# <pkg>.overrideAttrs (finalAttrs: previousAttrs: { buildFeatures = [ "client-nogui" "release-build" ] })

	# Build
	buildType = "release"; # cargo build --profile [buildType]
	# enable/disable these flags using an overlay if you wish, there is also with-gui for a client GUI
	buildNoDefaultFeatures = true;
	buildFeatures = [ "with-client" "with-server" "release-build" ];

	# Check
	useNextest = true; # upstream uses nextest
	checkType = "test"; # cargo nextest run --cargo-profile test / cargo test --profile test
	checkNoDefaultFeatures = true;
	checkFeatures = [ "with-client" "with-server" ]; # cargo nextest run --features [checkFeatures]
	cargoTestFlags = [ "--package ruroco" "--retries 2" ]; # cargo nextest run [cargoTestFlags] -- [checkFlags]
	checkFlags = [ "--skip destination_ips" ]; # skip tests that require internet access; buildRustPackage runs cargo with --offline

	# Prefix vague default binary filenames with "ruroco-"
	postInstall = ''
		cd $out/bin
		[ -x client ] && mv {,ruroco-}client || true
		[ -x client_ui ] && mv client_ui ruroco-client-ui || true
		[ -x commander -a -x server ] && mv {,ruroco-}commander && mv {,ruroco-}server || true
	'';

	passthru.tests = {
		end-to-end = nixosTests.ruroco;
	};
}
