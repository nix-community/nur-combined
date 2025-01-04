{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
	pname = "week-number";
	version = "1.2.0";

	src = fetchurl {
		name = "Week-Number.zip";
		url = "https://www.dropbox.com/scl/fi/l2yr5m6il2wqjnftl6uoi/Week-Number-1.2.0-1734647649.zip?rlkey=ehuk5cftyrumqsrxwi6d8am94&raw=1";
		hash = "sha256-NXSpsG5va3RNfC0NHWKW2m+jP8W4CzIOmlNNc6ena8c=";
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
		mv "Week Number.app" $out/Applications
		runHook postInstall
	'';

	passthru = {
		"1.1.0" = finalAttrs.overrideAttrs {
			version = "1.1.0";
			src = fetchurl {
				name = "Week-Number.zip";
				url = "https://github.com/user-attachments/files/18203839/Week.Number.1.1.0.zip";
				hash = "sha256-ENYx5R9jHwwW/rblo9zIaAoKuaDlkGpp4RoAbcdcgn0=";
			};
		};
		"1.0.1" = finalAttrs.overrideAttrs {
			version = "1.0.1";
			src = fetchurl {
				name = "Week-Number.zip";
				url = "https://www.dropbox.com/scl/fi/cbxr3kcr4x58lhangw57z/Week-Number-1.0.1-1716246386.zip?rlkey=59zj9nr3osxon72zqvlpqv4qz&raw=1";
				hash = "sha256-GEbGHK9WNJnewEZ0DdFu2jPXHnN0mXE16lE0zk53Dhw=";
			};
		};
	};

	meta = {
		description = "The current week number in your menu bar";
		homepage = "https://sindresorhus.com/week-number";
		license = lib.licenses.unfree;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = [
			"aarch64-darwin"
			"x86_64-darwin"
		];
	};
})
