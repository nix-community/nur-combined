{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "archichect";
	version = "2.5";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/05/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-6WftBqYKSqSgkOizR5dtrAcPAvIfTY3+KRJaoFhyFhA=";
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
		mv ArchiChect.app ${applications}
		mkdir -p ${docs}
		mv *.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Check any app, bundle or file for 64-bit compatibility, signatures, notarization, and quarantine";
		longDescription = ''
			Drag and drop, or Open, almost any app, bundle, command tool, Installer package, even signed AppleScripts and regular documents, and ArchiChect will tell you whether its quarantine flag is set, if it contains executable code whether that is fully 64-bit, whether it has a valid signature, and whether it has been notarized, delivered by the App Store, or signed by Apple. The ultimate tool for checking compatibility, and more.
		'';
		homepage = "https://eclecticlight.co/32-bitcheck-archichect/";
		license = lib.licenses.unfree;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = [
			"aarch64-darwin"
			"x86_64-darwin"
		];
	};
})
