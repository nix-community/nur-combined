{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "lockrattler";
	version = "4.37";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/05/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-4DE+cRYTbZggHAGwnu/joiGIlXnevmhFfohIi/pgt44=";
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
		mv LockRattler.app ${applications}
		mkdir -p ${docs}
		mv *.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "A quick check of your security systems";
		longDescription = ''
			LockRattler checks your Mac’s basic security systems are active, reports version numbers of security configuration files which are active, the latest updates installed, and makes it easy to check for and install updates. Ideal for checking that SIP is enabled, and it has Apple’s latest silent security updates.
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
