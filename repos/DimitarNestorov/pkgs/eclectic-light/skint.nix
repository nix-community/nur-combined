{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	pname = "skint";
	cleanVersion = version: builtins.replaceStrings ["."] [""] version;
	install = app: version: let
		container = "${pname}${version}";
		applications = "$out/Applications";
		docs = "$doc/share/doc/${pname}";
	in ''
		runHook preInstall
		unzip $src
		mkdir -p ${applications}
		mv ${container}/${app} ${applications}
		mkdir -p ${docs}
		mv ${container}/*.{rtf,pdf,plist} ${docs}
		runHook postInstall
	'';
in rec {
	inherit pname;
	version = "1.08";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2024/08/${pname}${cleanVersion finalAttrs.version}.zip";
		hash = "sha256-8BmvMbols8H5PZTlzVdk1JvTD569H0ThOARlTzs5lUg=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "Skint.app";
	installPhase = install sourceRoot (cleanVersion finalAttrs.version);

	outputs = [
		"out"
		"doc"
	];

	passthru.m = stdenvNoCC.mkDerivation (finalAttrs: rec {
		inherit version src meta dontPatch dontConfigure dontBuild dontFixup dontUnpack nativeBuildInputs outputs;
		pname = "skint-m";
		sourceRoot = "SkintM.app";
		installPhase = install sourceRoot (cleanVersion finalAttrs.version);
	});

	meta = {
		description = "A watchful eye on security settings";
		longDescription = ''
			Checks key security settings and features including SIP, SSV, Gatekeeper, XProtect, XProtect Remediator and macOS security updates. Runs automatically every 24 hours showing green/amber/red and any issues. Doesn’t check Apple’s software update servers, and tolerant of Macs running older versions of macOS.
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