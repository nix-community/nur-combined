{
	lib,
	stdenvNoCC,
	fetchurl,
	unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
	pname = "velja";
	version = "2.0.6";

	src = fetchurl {
		name = "Velja.zip";
		url = "https://www.dropbox.com/scl/fi/5k2qcg8t0hzs4jnksszua/Velja-${finalAttrs.version}-1725095798.zip?rlkey=rsi892nrgf4mfpefad4osohj2&raw=1";
		hash = "sha256-oWS1xVIJ45CKllSnC2+pKarKHf2IO07C16HdQXVjK3w=";
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
		mv Velja.app $out/Applications
		runHook postInstall
	'';

	passthru = {
		"2.0.3" = finalAttrs.overrideAttrs {
			version = "2.0.3";
			src = fetchurl {
				name = "Velja.zip";
				url = "https://www.dropbox.com/scl/fi/evv8iq8elftl6exlc17zd/Velja-2.0.3-1716983176.zip?rlkey=12jx6j3gzuv3cnwd8ky5a14wy&raw=1";
				hash = "sha256-oM/0MtemXkP6emxht4rt8RU3XC9A3xmyzcJNb1wZdIA=";
			};
		};
		"2.0.0" = finalAttrs.overrideAttrs {
			version = "2.0.0";
			src = fetchurl {
				name = "Velja.zip";
				url = "https://www.dropbox.com/scl/fi/8r0aij7ya4dtm0a1sse1x/Velja-2.0.0-1710312275.zip?rlkey=lxg22hq2rjrlic4mi43p480az&raw=1";
				hash = "sha256-fRL0Abwq26H3lqZ9XJBQLX3On7WWTtCRUQb7v52j/ho=";
			};
		};
		"1.16.4" = finalAttrs.overrideAttrs {
			version = "1.16.4";
			src = fetchurl {
				name = "Velja.zip";
				url = "https://github.com/sindresorhus/meta/files/14577839/Velja.1.16.4.-.macOS.13.zip";
				hash = "sha256-gD9ilvU5r9doGDaT0TCytQUy2rc3x5vDGAsz6NVATHc=";
			};
		};
		"1.13.0" = finalAttrs.overrideAttrs {
			version = "1.13.0";
			src = fetchurl {
				name = "Velja.zip";
				url = "https://www.dropbox.com/scl/fi/1sf7n8lod0pmegxxvsios/Velja-1.13.0-1678086159-1701610839.zip?rlkey=y1cbs7utnpp5f38x2i9octxps&raw=1";
				hash = "sha256-Rv80pyadPLJvT8WYt6GdXtqfPRqzu815lq0FpK6YBBo=";
			};
		};
		"1.12.4" = finalAttrs.overrideAttrs {
			version = "1.12.4";
			src = fetchurl {
				name = "Velja.zip";
				url = "https://github.com/sindresorhus/meta/files/10895250/Velja.1.12.4.-.macOS.12.zip";
				hash = "sha256-D2up0tyKLtoLuGi63DTE2iXzI8JbB8B1YEbK4Ws4mPA=";
			};
		};
	};

	meta = {
		description = "Powerful browser picker";
		longDescription = ''
			Velja lets you to open links in specific browser or browser profile, switch between browsers effortlessly, and directly launch desktop apps for specific websites, like opening Zoom links in the Zoom app. It enhances privacy by stripping tracking parameters from URLs and allows for the creation of advanced rules, such as opening links from certain apps in a specific browser.
		'';
		homepage = "https://sindresorhus.com/velja";
		license = lib.licenses.unfree;
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
		maintainers = with lib.maintainers; [ DimitarNestorov ];
		platforms = [
			"aarch64-darwin"
			"x86_64-darwin"
		];
	};
})
