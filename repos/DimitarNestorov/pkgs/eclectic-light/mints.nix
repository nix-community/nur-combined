{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "mints";
	version = "1.20";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2024/11/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-JEZxvaWaWuPY8jLm37CTyBqnDKo+/SCykoEkowFYNdE=";
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
		mv Mints.app ${applications}
		mkdir -p ${docs}
		mv *.{rtf,pdf} ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "A multifunction utility";
		longDescription = ''
			Mints is a growing collection of tools which provide tailor-made log extracts for investigating problems and exploring macOS, collate various information about a Mac which can be difficult to find elsewhere, perform a set of tests on Spotlight, and provide specialist tools for certain types of data. It’s aimed primarily at the advanced user, system administrator, support folk, and developers, although its tools are simple to use.
		'';
		homepage = "https://eclecticlight.co/mints-a-multifunction-utility/";
		license = lib.licenses.unfree;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = [
			"aarch64-darwin"
			"x86_64-darwin"
		];
	};
})
