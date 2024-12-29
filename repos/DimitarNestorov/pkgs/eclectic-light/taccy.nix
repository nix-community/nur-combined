{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "taccy";
	version = "1.15";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/06/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-1fHwD/EFAHyKZPJ3qiMKDK8eqJoZ50LZcvMp0Gev18M=";
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
		mv Taccy.app ${applications}
		mkdir -p ${docs}
		mv *.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Troubleshoot signature and privacy problems";
		longDescription = ''
			Taccy examines an app’s Info.plist file and its code signature to discover its full settings for accessing protected data, particularly in Mojave. Helps you decide whether to add it to Full Disk Access, and debug problems with the privacy system, TCC. Ideal for advanced users, sysadmins, developers, security researchers, and anyone exploring macOS.
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
