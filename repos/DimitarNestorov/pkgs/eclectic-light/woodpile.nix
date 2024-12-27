{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "woodpile";
	version = "1.0b6";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2017/12/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-ZhluhwN9JMT7yNhH1mCpYK1wM8HMgosYLFPYJd+35ZU=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "Woodpile.app";
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
		mv ${container}/*.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "A new type of log browser, which explores long periods from the top down";
		longDescription = ''
			Woodpile analyses records in any logarchive for the processes which write to the log most, and shows you for each selected process when they did so. This lets you examine those log files in more detail, to hone in on performance and other problems. A unique approach to the vast amounts of data stored in the new macOS log. Also shows important events like startup, creates frequency charts for custom processes, and links windows to a common time period.
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
