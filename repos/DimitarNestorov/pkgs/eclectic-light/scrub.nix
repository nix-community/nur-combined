{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "scrub";
	version = "1.3";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/06/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-1FN7wFYV/LTvKgCwQqSUsHG5z660ztfoiE/TlFA0ZV0=";
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
		mv Scrub.app ${applications}
		mkdir -p ${docs}
		mv *.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Cleans folders and volumes of potentially leaking sensitive data";
		longDescription = ''
			Scrub clears extended attributes which can show when a file was downloaded, and where from; old versions; turns off Spotlight indexing; clears the QuickLook cache; can even set all file dates to 1970. These greatly limit the forensic footprint of your most sensitive files. Powerful, so please read the docs carefully before use.
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
