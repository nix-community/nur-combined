{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "dispatchview";
	version = "1.0";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2017/09/${pname}${removeDot finalAttrs.version}a.zip";
		hash = "sha256-cnK/zrDTuR02XSP2GqqldWhMWa3vRuOZoUrGZTQFJcM=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "DispatchView.app";
	installPhase = let
		container = "${pname}${removeDot finalAttrs.version}a";
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
		description = "Analyses the log for task dispatching issues";
		longDescription = ''
			DispatchView shows log entries for two key systems DAS and CTS whose failure can result in Time Machine backups becoming irregular or stopping altogether, and may be involved in apps or services stalling or behaving unreliably. It can save you lots of effort using Consolation.
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
