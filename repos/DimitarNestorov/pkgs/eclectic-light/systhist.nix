{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "systhist";
	version = "1.20";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2024/08/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-xTwIKJ7NT0K8ylROALcUDTDPYwW8u/wooyxa0UmoepU=";
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
		mv SystHist.app ${applications}
		mkdir -p ${docs}
		mv *.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Lists full system and security update installation history";
		longDescription = ''
			SystHist is a clean and simple app which tells you all the OS X/macOS system and security updates which have been installed on that Mac. Now probes deep into protected territory to find even silent silent updates, and gives details of all the files updated.
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
