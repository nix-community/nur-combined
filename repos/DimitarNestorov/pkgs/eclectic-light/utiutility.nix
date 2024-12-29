{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "utiutility";
	version = "1.3";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/06/utiutil${removeDot finalAttrs.version}.zip";
		hash = "sha256-gBax7lIxL2sGwdtZlmcnNe/iRyeKbQOmbZfusgy8YwM=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "utiutil${removeDot finalAttrs.version}";
	installPhase = let
		applications = "$out/Applications";
		docs = "$doc/share/doc/${pname}";
	in ''
		runHook preInstall
		mkdir -p ${applications}
		mv UTIutility.app ${applications}
		mkdir -p ${docs}
		mv *.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "UTI scanning and conversion utility";
		longDescription = ''
			UTIutility can scan folders to discover and list all the different UTI type designators used, and converts between UTIs, filename extensions, MIME types, and more.
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
