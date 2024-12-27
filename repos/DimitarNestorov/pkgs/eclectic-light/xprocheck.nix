{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "xprocheck";
	version = "1.6";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2024/07/${pname}${removeDot finalAttrs.version}-1.zip";
		hash = "sha256-Z3X9m+tE0BigKHoAuUTcOaQCdjmFzaoZWYt9ERZ9q6o=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "XProCheck.app";
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
		description = "Check on XProtect Remediator scans completed and reported in the log";
		longDescription = ''
			Inspects the Unified log for a period of 1-30 days and reports all completed and reported anti-malware scans by modules of XProtect Remediator. Enables you to confirm that scans are occurring, and whether any detect or remediate malware.
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
