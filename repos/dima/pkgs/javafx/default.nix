{ pkgs }:

pkgs.stdenv.mkDerivation {
	pname = "javafx";
	version = "21.0.12";

	src = pkgs.fetchurl {
		url = "https://download2.gluonhq.com/openjfx/21.0.12/openjfx-21.0.12_linux-x64_bin-sdk.zip";
		hash = "sha256-nU49ql8uwHqMrOwvio9W1Ie5mq33V8GPXx8cL7WUdAs=";
	};

	nativeBuildInputs = with pkgs; [
		unzip
	];

	unpackPhase = ''
		unzip $src
	'';

	dontBuild = true;

	installPhase = ''
		mkdir -p $out
		cp -r javafx-sdk-21.0.12/. $out
	'';

	meta = with pkgs.lib; {
		description = "Open source, next generation client application platform for desktop, mobile and embedded systems built on Java";
		homepage = "https://github.com/openjdk/jfx";
		license = {
			fullName = "GNU General Public License v2.0 w/Classpath exception";
			spdxId = "GPL-2.0-with-classpath-exception";
			url = "https://openjdk.org/legal/gplv2+ce.html";
			free = true;
		};
		sourceProvenance = sourceTypes.binaryBytecode;
	};
}
