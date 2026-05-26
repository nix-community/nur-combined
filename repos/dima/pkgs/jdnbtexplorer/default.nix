{ pkgs, nbt }:

pkgs.python3Packages.buildPythonPackage {
	pname = "jdNBTExplorer";
	version = "3.0";
	src = pkgs.fetchFromCodeberg {
		owner = "JakobDev";
		repo = "jdNBTExplorer";
		tag = "3.0";
		hash = "sha256-dtm45o/xXgVAx86QtrQAusZ6zKyjD1+1PxY0GBXCqXQ=";
	};

	format = "pyproject";

	nativeBuildInputs = with pkgs; with python3Packages; [
		setuptools

		pyqt6
		kdePackages.qttools
	];

	propagatedBuildInputs = with pkgs; with python3Packages; [
		pyqt6
		kdePackages.wrapQtAppsHook
		nbt
	];

	postInstall = ''
		mkdir -p $out/share/applications/
		mkdir -p $out/share/icons/hicolor/256x256/apps/

		cp jdNBTExplorer/Logo.png $out/share/icons/hicolor/256x256/apps/page.codeberg.JakobDev.jdNBTExplorer.png

		cp ./deploy/page.codeberg.JakobDev.jdNBTExplorer.desktop $out/share/applications/
	'';

	meta = with pkgs.lib; {
		description = "Editor for Minecraft NBT files";
		license = licenses.gpl3Only;
		mainProgram = "jdNBTExplorer";
		homepage = "https://codeberg.org/JakobDev/jdNBTExplorer";
	};
}
