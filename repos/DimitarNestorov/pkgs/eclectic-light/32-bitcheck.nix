{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "32-bitcheck";
	version = "1.8";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2019/06/32bitcheck${removeDot finalAttrs.version}.zip";
		hash = "sha256-zhuwiHFcQHEmLjlwUh/UcU+nfUQ1LHvPEW4QadN+s+s=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "32bitCheck${removeDot finalAttrs.version}";
	installPhase = let
		applications = "$out/Applications";
		docs = "$doc/share/doc/${pname}";
	in ''
		runHook preInstall
		mkdir -p ${applications}
		mv 32-bitCheck.app ${applications}
		mkdir -p ${docs}
		mv *.{pdf,rtf} ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Checks installed apps, code bundles, command tools and more for those which are 32-bit";
		longDescription = ''
			32-bitCheck is a much better tool for checking which apps and other software are still 32-bit. Check the folders of your choosing, and can check just apps, or all bundles including plugins and other executable code. Generates text reports to help you prepare your Mac for macOS 10.14 later this year. Why waste time and effort using System Information?
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
