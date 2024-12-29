{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
	pname = "daisydisk";
	version = "4.30";

	src = fetchurl {
		url = "https://daisydiskapp.com/download/DaisyDisk.zip";
		hash = "sha256-HMjqeQ5kzrUDOqMyEoBncTETWZixoeAcmNty35Y/mNs=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = ".";
	installPhase = ''
		runHook preInstall

		mkdir -p $out/Applications
		mv DaisyDisk.app $out/Applications

		runHook postInstall
	'';

	meta = {
		description = "Find out what’s taking up your disk space and recover it in the most efficient and easy way";
		homepage = "https://daisydiskapp.com/";
		changelog = "https://daisydiskapp.com/releases";
		license = [ lib.licenses.unfree ];
		sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = lib.platforms.darwin;
	};
})
