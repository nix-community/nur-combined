{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "signet";
	version = "1.3";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2020/09/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-6kjndXfkaEjVo4YXgt2q8FpyXmpPFIAu4pvCC9iK61A=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "Signet.app";
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
		mv ${container}/*.{rtf,pdf} ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Scans and checks bundle signatures";
		longDescription = ''
			Scans a selected folder looking for apps and other bundles. For each found, checks it signature and reports any problems, including revocation, missing signature, or obsolete signature type. Invaluable for finding gronky old software, apps which have had their certificates revoked, and more.
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
