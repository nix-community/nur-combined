{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: let
	removeDot = version: builtins.replaceStrings ["."] [""] version;
in rec {
	pname = "precize";
	version = "1.15";

	src = fetchurl {
		url = "https://eclecticlight.co/wp-content/uploads/2024/08/${pname}${removeDot finalAttrs.version}.zip";
		hash = "sha256-WTOUQqfmYtbeXq+yd5toEabSfgkZ2qcZJLkhElxW9mw=";
	};

	dontPatch = true;
	dontConfigure = true;
	dontBuild = true;
	dontFixup = true;
	dontUnpack = true;

	nativeBuildInputs = [ unzip ];

	sourceRoot = "Precize.app";
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
		mv ${container}/*.pdf ${docs}
		runHook postInstall
	'';

	outputs = [
		"out"
		"doc"
	];

	meta = {
		description = "Looks deep into files, bundles and folders to show their full size including extended attributes";
		longDescription = ''
			Drag and drop items onto Precize and it tells you how much space they really take on disk, including all their extended attributes. It lists all inode data and gives volfs and File Reference URL paths to an item. It also provides macOS Bookmarks, and its integrated Bookmark Resolver locates and previews files from their Bookmarks.
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
