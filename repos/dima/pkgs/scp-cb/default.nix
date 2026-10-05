{
	pkgs,
	dataRoot,
	savesDirectory ? "${dataRoot}/Saves",
}:

pkgs.stdenv.mkDerivation {
	pname = "scp-cb";
	version = "1.3.11";

	src = pkgs.fetchurl {
		url = "https://undertowgames.com/file/scp/SCP%20-%20Containment%20Breach%20v1.3.11.zip";
		hash = "sha256-zgu/pbqs8JWHNzQ3ezP6VdMe4JhRbgPGNx2dyYalMAA=";
	};

	nativeBuildInputs = with pkgs; [
		unzip
		makeWrapper
		initool
		copyDesktopItems
		imagemagick
	];

	buildInputs = with pkgs; [
		wine
	];

	desktopItems = [
		(pkgs.makeDesktopItem {
			name = "scp-cb";
			desktopName = "SCP: Containment Breach";
			comment = "Free survival horror game based on the works of the SCP Foundation community";
			exec = "scp-cb";
			icon = "scp-cb";
			categories = [
				"Game"
			];
		})
	];

	unpackPhase = ''
		mkdir -p $out/{lib/scp-cb,share/icons/hicolor/64x64/apps}
		unzip $src -d $out/lib/scp-cb
	'';

	patchPhase = ''
		cp $out/lib/scp-cb/options.ini $out/lib/scp-cb/options.ini.bak
		tr -d '\015' <$out/lib/scp-cb/options.ini.bak >$out/lib/scp-cb/options.ini
		rm $out/lib/scp-cb/options.ini.bak

		cp $out/lib/scp-cb/options.ini $out/lib/scp-cb/options.ini.bak
		initool set $out/lib/scp-cb/options.ini.bak "launcher" "launcher enabled" "false" > $out/lib/scp-cb/options.ini
		rm $out/lib/scp-cb/options.ini.bak

		cp $out/lib/scp-cb/options.ini $out/lib/scp-cb/options.ini.bak
		initool set $out/lib/scp-cb/options.ini.bak "options" "play startup video" "false" > $out/lib/scp-cb/options.ini
		rm $out/lib/scp-cb/options.ini.bak

		cp $out/lib/scp-cb/options.ini $out/lib/scp-cb/options.ini.bak
		initool set $out/lib/scp-cb/options.ini.bak "options" "fullscreen" "true" > $out/lib/scp-cb/options.ini
		rm $out/lib/scp-cb/options.ini.bak

		cp $out/lib/scp-cb/options.ini $out/lib/scp-cb/options.ini.bak
		initool set $out/lib/scp-cb/options.ini.bak "options" "width" "3840" > $out/lib/scp-cb/options.ini
		rm $out/lib/scp-cb/options.ini.bak

		cp $out/lib/scp-cb/options.ini $out/lib/scp-cb/options.ini.bak
		initool set $out/lib/scp-cb/options.ini.bak "options" "height" "2160" > $out/lib/scp-cb/options.ini
		rm $out/lib/scp-cb/options.ini.bak
	'';

	installPhase = with pkgs; ''
		runHook preInstall

		mkdir -p $out/bin
		cp ${./scp-cb} $out/bin/scp-cb

		chmod +x $out/bin/scp-cb

		patchShebangs $out/bin/scp-cb
		wrapProgram $out/bin/scp-cb \
			--prefix PATH : ${wine}/bin

		mv $out/lib/scp-cb/options.ini $out/lib/scp-cb/options.ini.bak
		ln -s ${dataRoot}/options.ini $out/lib/scp-cb/options.ini

		mv $out/lib/scp-cb/Loadingscreens/loadingscreens.ini $out/lib/scp-cb/Loadingscreens/loadingscreens.ini.bak
		ln -s ${dataRoot}/loadingscreens.ini $out/lib/scp-cb/Loadingscreens/loadingscreens.ini

		mv $out/lib/scp-cb/Data/rooms.ini $out/lib/scp-cb/Data/rooms.ini.bak
		ln -s ${dataRoot}/rooms.ini $out/lib/scp-cb/Data/rooms.ini

		mv $out/lib/scp-cb/Data/materials.ini $out/lib/scp-cb/Data/materials.ini.bak
		ln -s ${dataRoot}/materials.ini $out/lib/scp-cb/Data/materials.ini

		rm -r $out/lib/scp-cb/Saves
		ln -s ${savesDirectory} $out/lib/scp-cb/Saves

		runHook postInstall
	'';

	postInstall = ''
		magick "$out/lib/scp-cb/logo.ico[3]" "$out/share/icons/hicolor/64x64/apps/scp-cb.png"
	'';

	meta = with pkgs.lib; {
		description = "Free survival horror game based on the works of the SCP Foundation community";
		homepage = "https://github.com/Regalis11/scpcb";
		license = licenses.unfree;
		mainProgram = "scp-cb";
	};
}
