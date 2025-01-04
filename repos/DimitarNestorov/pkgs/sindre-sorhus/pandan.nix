{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
	pname = "pandan";
	version = "1.16.0";

	src = fetchurl {
		name = "Pandan.zip";
		url = "https://www.dropbox.com/scl/fi/hlvorsw06mvf832dt2e3q/Pandan-${finalAttrs.version}-1707587381.zip?rlkey=r2xffuz4jietc7p0jagtrt7r4&raw=1";
		hash = "sha256-dBuFu+T9lWCm4L7+EyogCxOoV5B5wsB3J9mgTTzaUN4=";
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
		mv Pandan.app $out/Applications
		runHook postInstall
	'';

	passthru = {
		"1.15.0" = finalAttrs.overrideAttrs {
			version = "1.15.0";
			src = fetchurl {
				name = "Pandan.zip";
				url = "https://github.com/sindresorhus/meta/files/14230031/Pandan.1.15.0.-.macOS.13.zip";
				hash = "sha256-i9QXmI+bvjxQNaWt6FLq6iAOlYV+y7IFewwHgnm/qXQ=";
			};
		};
		"1.14.0" = finalAttrs.overrideAttrs {
			version = "1.14.0";
			src = fetchurl {
				name = "Pandan.zip";
				url = "https://www.dropbox.com/scl/fi/p80m81nllztkjzj1exhy8/Pandan-1.14.0-1679831725-1701610376.zip?rlkey=kri87h01pq3zxzetbidbc4znh&raw=1";
				hash = "sha256-yzdgTeW1ZYzzGWgsOoUHv83datUBXFLpUJKxgYJtRnI=";
			};
		};
		"1.13.2" = finalAttrs.overrideAttrs {
			version = "1.13.2";
			src = fetchurl {
				name = "Pandan.zip";
				url = "https://github.com/sindresorhus/meta/files/11072195/Pandan.1.13.2.-.macOS.12.zip";
				hash = "sha256-RcR/RcMyALjnKyq7a8YIo8dkIOyqmAJeqgpBol/OGFk=";
			};
		};
		"1.9.1" = finalAttrs.overrideAttrs {
			version = "1.9.1";
			src = fetchurl {
				name = "Pandan.zip";
				url = "https://github.com/sindresorhus/meta/files/8003835/Pandan.1.9.1.-.macOS.11.zip";
				hash = "sha256-dlt/w3BlM4l6ijlkErfnMQd/M0GifMSaR75tvXY57lo=";
			};
		};
	};

	meta = {
		description = "Time awareness in your menu bar";
		longDescription = ''
			Pandan is a time awareness tool, not a traditional time tracker or break reminder. It shows you how long you have been actively using your computer, to make you aware and let you decide when it's time to take a break. We all know how easy it is to get lost in an exciting task.
		'';
		homepage = "https://sindresorhus.com/pandan";
		license = lib.licenses.unfree;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = [
			"aarch64-darwin"
			"x86_64-darwin"
		];
	};
})
