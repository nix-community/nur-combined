{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "consolation";
	version = "3.13";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2021/04/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-z2zWOOa7IRa1uHsIgNWrj+Yb7gqo7n7OqZizqCFCvr4=";
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
		mv Consolation3.app ${applications}
		mkdir -p ${docs}
		mv *.{rtf,pdf} ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "A log browser for macOS";
		longDescription = ''
			Consolation provides an accessible but powerful way to browse, search, and analyse entries in the new log system which have already been captured. This is not supported by Apple’s Console app. If you want to check that Time Machine backups have been made on time and without error, or get to the bottom of startup, extension, or many other problems, Consolation is the only practical tool to use.
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
