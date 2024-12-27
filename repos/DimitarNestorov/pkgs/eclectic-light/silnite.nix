{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
	versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
	pname = "silnite";
	version = "10";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/07/${pname}${finalAttrs.version}.zip";
		hash = "sha256-LPVgB6ng9NQgzBN6/raBHe0JGNdNSVUuaEIYtxJ8yXY=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	installPhase = ''
		runHook preInstall
		unzip $src
		mkdir -p $out/bin
		mv ${pname}${finalAttrs.version}/${pname} $out/bin
		mkdir -p $doc/share/doc/${pname}
		mv ${pname}${finalAttrs.version}/*.txt $doc/share/doc/${pname}
		runHook postInstall
	'';

	nativeInstallCheckInputs = [ versionCheckHook ];
	doInstallCheck = true;

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "A command tool to perform the same checks as SilentKnight";
		longDescription = ''
			If you’re managing Macs on a network, this is an invaluable way of checking EFI firmware, security settings including SIP and FileVault, and security data file updates. A choice of two levels of detail, which can include checks against my database of current versions, and reports to stdout in text, JSONised XML or proper JSON.
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
