{ pkgs, javafx }:

pkgs.stdenv.mkDerivation {
	name = "mcaselector";
	version = "2.8.0";

	src = pkgs.fetchurl {
		url = "https://github.com/Querz/mcaselector/releases/download/2.8/mcaselector-2.8.jar";
		hash = "sha256-ZFBfOe35ybXUfmZpgfgePDqInU8SKzBlr34mn0jlNCM=";
	};

	nativeBuildInputs = with pkgs; [
		makeWrapper
	];

	dontUnpack = true;
	dontBuild = true;

	installPhase = ''
		mkdir -p $out/{bin,lib}

		cp $src $out/lib/mcaselector-2.8.jar

		makeWrapper ${pkgs.jre}/bin/java $out/bin/mcaselector \
			--prefix LD_LIBRARY_PATH : ${
				pkgs.lib.makeLibraryPath [
					pkgs.glib.out
				]
			} \
			--add-flags "--module-path ${javafx}/lib" \
			--add-flags "--add-modules=javafx.controls,javafx.swing" \
			--add-flags "-jar $out/lib/mcaselector-2.8.jar"
	'';

	meta = with pkgs.lib; {
		mainProgram = "mcaselector";
		description = "External tool to export or delete selected chunks and regions from a world save of Minecraft Java Edition";
		homepage = "https://github.com/Querz/mcaselector";
		license = licenses.mit;
		sourceProvenance = sourceTypes.binaryBytecode;
	};
}
