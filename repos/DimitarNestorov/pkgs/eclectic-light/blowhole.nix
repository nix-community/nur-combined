{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
	versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
	pname = "blowhole";
	version = "11";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2023/07/${pname}${finalAttrs.version}.zip";
		hash = "sha256-5KeWzpszSs6WJCsUZ8Nn1CKx58qQG3mlv3IJmiBC6U0=";
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
		mv *.{txt,plist} ${docs}
		runHook postInstall
	'';

	nativeInstallCheckInputs = [ versionCheckHook ];
	doInstallCheck = true;

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "A command tool to write into the log in macOS Sierra and later";
		longDescription = ''
			Blowhole is a command tool, which can be run in Terminal or called from any app or scripting language with support for calling command tools, which writes out an entry in Sierra’s new log system. Use this to check running of periodic tasks, or from any scripting language which does not have direct access to the new log.
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
