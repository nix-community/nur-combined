{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "alifix";
	version = "1.3";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/06/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-YvCaa9uZHGzEcgZ7fNqh9Ljp5TDedOdeRGvz4yk/7p0=";
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
		mv Alifix.app ${applications}
		mkdir -p ${docs}
		mv *.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Refreshes Aliases and identifies broken Aliases";
		longDescription = ''
			Scans folders deeply to identify and refresh all Finder Aliases, including those made by alisma. Reports all that are broken, and optionally writes adjacent text file with their internal details to help you repair the Alias. Ideal before and after cloning or copying large folders or volumes, and as periodic housekeeping.
		'';
		homepage = "https://eclecticlight.co/taccy-signet-precize-alifix-utiutility-alisma/";
		license = lib.licenses.unfree;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = [
			"aarch64-darwin"
			"x86_64-darwin"
		];
	};
})
