{
	lib,
	rustPlatform,
	fetchFromGitHub,
	makeWrapper,
	pkg-config,
	desktop-file-utils,
	fontconfig,
	freetype,
	vulkan-loader,
	wayland,
	libxkbcommon,
	libx11,
	libxcb,
	gh,
	git,
	jujutsu,
	nix,
	package ? "nixbox",
	buildJobs ? 2,
}:
let
	release = builtins.fromJSON (builtins.readFile ./source.json);
	gui = package == "nixbox";
	binary = if gui then "nixbox-gui" else package;
	limitBuildJobs = ''
		if (( NIX_BUILD_CORES > ${toString buildJobs} )); then
			export NIX_BUILD_CORES=${toString buildJobs}
		fi
		export CARGO_BUILD_JOBS="$NIX_BUILD_CORES"
	'';
	guiLibraries = [
		vulkan-loader
		wayland
		libxkbcommon
		libx11
		libxcb
	];
in
assert lib.assertMsg (builtins.isInt buildJobs && buildJobs > 0)
	"NixBox buildJobs must be a positive integer";
assert builtins.elem package [ "nixbox" "nixbox-tui" "nixbox-cli" ];
rustPlatform.buildRustPackage {
	pname = package;
	inherit (release) version;
	src = fetchFromGitHub {
		owner = "SINGH-RAJVEER";
		repo = "nixbox";
		inherit (release) rev hash;
	};

	# A local lock file keeps restricted NUR evaluation independent of fetching.
	cargoLock.lockFile = ./Cargo.lock;
	preBuild = limitBuildJobs;
	preCheck = limitBuildJobs;
	useNextest = true;
	nativeCheckInputs = [ git jujutsu ];
	cargoBuildFlags = [ "--package" package ] ++ lib.optionals gui [ "--features" "native" ];
	cargoTestFlags =
		if gui then [ "--package" "nixbox" "--features" "native" ]
		else if package == "nixbox-tui" then [ "--workspace" "--exclude" "nixbox" ]
		else [ "--package" "nixbox-cli" "--package" "nixbox-cmd" ];

	nativeBuildInputs = [ makeWrapper ] ++ lib.optionals gui [ pkg-config desktop-file-utils ];
	buildInputs = lib.optionals gui (guiLibraries ++ [ fontconfig freetype ]);

	postInstall = ''
		for executable in ${binary}${lib.optionalString (package == "nixbox-cli") " nixbox nb"}; do
			wrapProgram "$out/bin/$executable" \
				--prefix PATH : ${lib.makeBinPath [ gh git jujutsu nix ]}${
					lib.optionalString gui " --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath guiLibraries}"
				}
		done
		${lib.optionalString gui ''
			install -Dm644 assets/nixbox.svg "$out/share/icons/hicolor/scalable/apps/nixbox.svg"
			install -Dm644 assets/nixbox.desktop.in "$out/share/applications/nixbox.desktop"
			substituteInPlace "$out/share/applications/nixbox.desktop" \
				--replace-fail '@NIXBOX_EXEC@' "$out/bin/nixbox-gui"
			desktop-file-validate "$out/share/applications/nixbox.desktop"
		''}
	'';

	meta = {
		description =
			if gui then "Desktop package manager for NixOS and Home Manager"
			else if package == "nixbox-tui" then "Terminal UI package manager for NixOS and Home Manager"
			else "Command-line package manager for NixOS and Home Manager";
		homepage = "https://github.com/SINGH-RAJVEER/nixbox";
		changelog = "https://github.com/SINGH-RAJVEER/nixbox/blob/${release.rev}/docs/RELEASE_NOTES.md";
		license = lib.licenses.asl20;
		mainProgram = binary;
		platforms = [ "x86_64-linux" "aarch64-linux" ] ++ lib.optional (!gui) "aarch64-darwin";
	};
}
