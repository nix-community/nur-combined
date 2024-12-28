{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "sparsity";
	version = "1.3";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/04/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-nrg2DfOMABe4a4ET2z7BXho+SPWvfKd9aSJ41bXsuWc=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "Sparsity.app";
	installPhase = let
		container = "${pname}${removeDot finalAttrs.version}";
		applications = "$out/Applications";
		docs = "$doc/share/doc/${pname}";
	in ''
		runHook preInstall
		unzip $src
		mkdir -p ${applications}
		mv ${container}/${sourceRoot} ${applications}
		mkdir -p ${docs}
		mv ${container}/*.rtf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Create and find APFS sparse files";
		longDescription = ''
			Sparsity creates APFS sparse files up to 999 GB in (expanded) size, and crawls through every file in a folder or volume to report which are in sparse format or have been cloned. For those, it gives expanded and sparse size, and the sparsity ratio (equivalent to a compression ratio).
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
