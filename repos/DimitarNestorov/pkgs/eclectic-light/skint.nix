{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "skint";
	version = "1.08";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2024/08/skint${removeDot finalAttrs.version}.zip";
		hash = "sha256-8BmvMbols8H5PZTlzVdk1JvTD569H0ThOARlTzs5lUg=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;

	nativeBuildInputs = [ unzip ];

	app = "Skint.app";
	sourceRoot = "skint${removeDot finalAttrs.version}";
	installPhase = let
		applications = "$out/Applications";
		docs = "$doc/share/doc/${finalAttrs.pname}";
	in ''
		runHook preInstall
		mkdir -p ${applications}
		mv ${finalAttrs.app} ${applications}
		mkdir -p ${docs}
		mv *.{rtf,pdf,plist} ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

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