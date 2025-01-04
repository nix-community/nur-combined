{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
	pname = "plain-text-editor";
	version = "1.4.0";

	src = fetchurl {
		name = "Plain-Text-Editor.zip";
		url = "https://www.dropbox.com/scl/fi/o4c1yceor1i75blq21k6z/Plain-Text-Editor-1.4.0-1707655107.zip?rlkey=sp7x6srayuld4gi8cuouevoef&raw=1";
		hash = "sha256-N7Y1pnLa61NgPbmig7+oiJItXPoI0TbqO33OsTkbO58=";
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
		mv "Plain Text Editor.app" $out/Applications
		runHook postInstall
	'';

	passthru = {
		"1.4.0" = finalAttrs.overrideAttrs {
			version = "1.4.0";
			src = fetchurl {
				name = "Plain-Text-Editor.zip";
				url = "https://www.dropbox.com/scl/fi/o4c1yceor1i75blq21k6z/Plain-Text-Editor-1.4.0-1707655107.zip?rlkey=sp7x6srayuld4gi8cuouevoef&raw=1";
				hash = "sha256-N7Y1pnLa61NgPbmig7+oiJItXPoI0TbqO33OsTkbO58=";
			};
		};
		"1.3.2" = finalAttrs.overrideAttrs {
			version = "1.3.2";
			src = fetchurl {
				name = "Plain-Text-Editor.zip";
				url = "https://github.com/sindresorhus/meta/files/14232390/Plain.Text.Editor.1.3.2.-.macOS.13.zip";
				hash = "sha256-Ck5nsbO0MBTiUWSihW4dUQtwGHioIgGTibWvosYnOeY=";
			};
		};
		"1.2.1" = finalAttrs.overrideAttrs {
			version = "1.2.1";
			src = fetchurl {
				name = "Plain-Text-Editor.zip";
				url = "https://www.dropbox.com/scl/fi/xluitd9zdak3enu7yu8eh/Plain-Text-Editor-1.2.1-1701610704.zip?rlkey=9ci6dbu6rkha5jiuxsji1m7k5&raw=1";
				hash = "sha256-B/bw9r8fPPQ/orcO19eQvT0HFqjtc3dNOd5HhrKCnes=";
			};
		};
	};

	meta = {
		description = "Simple distraction-free notepad";
		longDescription = ''
			Simple distraction-free text editor without any rich text nonsense. The simplicity is a feature.
		'';
		homepage = "https://sindresorhus.com/plain-text-editor";
		license = lib.licenses.unfree;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = [
			"aarch64-darwin"
			"x86_64-darwin"
		];
	};
})
