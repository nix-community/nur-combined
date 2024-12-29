{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "silentknight";
	version = "2.11";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2024/09/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-CD/h1q/lqpcAzBE/A+fS8hk5fPXaKhkGwfVupgBipuI=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "${pname}${removeDot finalAttrs.version}";
	installPhase = let
		applications = "$out/Applications";
		docs = "$doc/share/doc/${pname}";
	in ''
		runHook preInstall
		mkdir -p ${applications}
		mv SilentKnight.app ${applications}
		mkdir -p ${docs}
		mv *.{pdf,rtf} ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Fully automatic checks of firmware and security systems";
		longDescription = ''
			Check whether your Mac is up to date automatically. Covers firmware, security settings and data files, and now checks macOS malware scans.
		'';
		homepage = "https://eclecticlight.co/lockrattler-systhist/";
		license = lib.licenses.unfree;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = [
			"aarch64-darwin"
			"x86_64-darwin"
		];
	};
})