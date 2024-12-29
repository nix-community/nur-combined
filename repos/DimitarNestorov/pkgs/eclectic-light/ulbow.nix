{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "ulbow";
	version = "1.10";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/02/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-P9r8lAw0j2EbeEIpcnvFdriJ/K2aOWnsrDow8sM8XAs=";
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
		mv Ulbow.app ${applications}
		mkdir -p ${docs}
		mv *.{rtf,pdf} ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "A log browser designed for ease of use, for macOS Sierra to Sequoia";
		longDescription = ''
			Ulbow is the simplest browser for the macOS Unified Log, without losing any of the power of Consolation 3. Uses similar libraries of predicates, filters (including regex), and styles to determine what is shown and how, it’s ideal for the casual user as well as log addicts.
		'';
		homepage = "https://eclecticlight.co/consolation-t2m2-and-log-utilities/";
		license = lib.licenses.unfree;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = [
			"aarch64-darwin"
			"x86_64-darwin"
		];
	};
})
