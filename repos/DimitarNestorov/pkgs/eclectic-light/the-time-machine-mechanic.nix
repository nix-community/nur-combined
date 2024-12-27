{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "the-time-machine-mechanic";
	version = "2.02";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2024/01/t2m2${removeDot finalAttrs.version}.zip";
		hash = "sha256-Dv1+tEciTPhK9RTOZ33lE5svcax49kLxps/KSsiejOk=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "TheTimeMachineMechanic.app";
	installPhase = let
		container = "t2m2${removeDot finalAttrs.version}";
		applications = "$out/Applications";
		docs = "$doc/share/doc/t2m2";
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
		description = "A quick but thorough check of Time Machine backing up";
		longDescription = ''
			T2M2 analyses your Mac’s logs to discover whether Time Machine backups have been running normally, reporting any worrying signs or errors. You don’t need to be able to read or understand logs to be able to check for problems now. Reports regularity of backups, free space, and more. Detailed Help book explains results and advises.
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
