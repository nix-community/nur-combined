{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
	versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
	pname = "alisma";
	version = "4";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/07/${pname}${finalAttrs.version}.zip";
		hash = "sha256-FZ5UPpLMi5fyN1sGg01R70iT6SE9LEkIIs9B3Lv9kwo=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "${pname}${finalAttrs.version}";
	installPhase = let
		docs = "$doc/share/doc/${pname}";
	in ''
		runHook preInstall
		mkdir -p $out/bin
		mv ${pname} $out/bin
		mkdir -p ${docs}
		mv *.txt ${docs}
		runHook postInstall
	'';

	nativeInstallCheckInputs = [ versionCheckHook ];
	doInstallCheck = true;

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "A command tool to create Finder aliases, and to resolve them to full paths";
		longDescription = ''
			alisma is a small command tool which gives access to Finder aliases from Terminal and shell scripts. It has two options, one which creates a Finder alias to a given file/folder, the other which resolves an existing Finder alias to the full path to the file/folder.
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
