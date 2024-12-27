{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
	pname = "makelogarchive";
	version = "0.5a1";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2017/10/mla5.zip";
		hash = "sha256-JGLUJRjNg6JYIz2my6EUfnVuro1IzKFYfUcaNaq/17U=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "MakeLogarchive.app";
	installPhase = let
		container = "mla5";
		applications = "$out/Applications";
		docs = "$doc/share/doc/${pname}";
	in ''
		runHook preInstall
		unzip $src
		mkdir -p ${applications}
		mv ${container}/${sourceRoot} ${applications}
		mkdir -p ${docs}
		mv ${container}/*.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "A utility for creating logarchives readable by Console from ‘live’ logs or raw log folders";
		longDescription = ''
			This tool, in early development, copies the files and folders from /var/db or a copy of that, and places them in a logarchive format file so that they can be opened by Consolation, Console, or log. It now produces well-formed logarchive bundles, which can be used to browse pooled and individual tracev3 log files. It also catalogues the tracev3 log files in any well-formed log archive, showing start and end times for each.
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
