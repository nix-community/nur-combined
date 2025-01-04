{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
	pname = "pasteboard-viewer";
	version = "2.6.0";

	src = fetchurl {
		name = "Pasteboard-Viewer.zip";
		url = "https://www.dropbox.com/scl/fi/z6tj464zryabggzlydcy3/Pasteboard-Viewer-2.6.0-1705413886.zip?rlkey=dnap7eyta0e1xm28clsqkuclf&raw=1";
		hash = "sha256-fIa1wDnh/kZm4BVYN6/CFMyDNJHm9gCLmqT1KD3CVRI=";
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
		mv "Pasteboard Viewer.app" $out/Applications
		runHook postInstall
	'';

	passthru = {
		"2.5.1" = finalAttrs.overrideAttrs {
			version = "2.5.1";
			src = fetchurl {
				name = "Pasteboard-Viewer.zip";
				url = "https://github.com/sindresorhus/Pasteboard-Viewer/releases/download/v2.5.1/Pasteboard.Viewer.2.5.1.-.macOS.13.zip";
				hash = "sha256-M6Gibb5FhrG7g3n3Skxqzb34W1fJDcrVrXfEnxftOrc=";
			};
		};
		"2.4.1" = finalAttrs.overrideAttrs {
			version = "2.4.1";
			src = fetchurl {
				name = "Pasteboard-Viewer.zip";
				url = "https://github.com/sindresorhus/meta/files/13539167/Pasteboard-Viewer-2.4.1-macOS-12.zip";
				hash = "sha256-xU3QCoPq0F4azfYuicqV2nE5CuinQZndktw9insIY5c=";
			};
		};
		"2.2.2" = finalAttrs.overrideAttrs {
			version = "2.2.2";
			src = fetchurl {
				name = "Pasteboard-Viewer.zip";
				url = "https://github.com/sindresorhus/Pasteboard-Viewer/releases/download/v2.2.2/Pasteboard.Viewer.2.2.2.-.macOS.11.zip";
				hash = "sha256-CVwvTTyrLGar76jKd+aZVvF7MDhDYCUOIQEwNa4STKg=";
			};
		};
		"1.5.2" = finalAttrs.overrideAttrs {
			version = "1.5.2";
			src = fetchurl {
				name = "Pasteboard-Viewer.zip";
				url = "https://github.com/sindresorhus/Pasteboard-Viewer/releases/download/v1.5.1/Pasteboard.Viewer.1.5.2.-.macOS.10.15.zip";
				hash = "sha256-PO1CNiSwYj/RA8XY3GoUjx31wSsKzV/1k6Bi5IWPXq4=";
			};
		};
	};

	meta = {
		description = "Inspect the system pasteboards";
		longDescription = ''
			This is a developer utility that lets you inspect the various system pasteboards. This can be useful to ensure your app is putting the correct data on NSPasteboard or UIPasteboard. The app refreshes the pasteboard contents live and can preview text, RTF, images, and anything that has a Quick Look preview.
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
