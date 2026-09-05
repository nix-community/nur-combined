{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, gtk3
, glib
, cairo
, pango
, gdk-pixbuf
, atk
, libX11
, libXext
, libXrender
, libXinerama
, libXrandr
, libSM
, libICE
, libGL
, libxkbcommon
, fontconfig
, expat
, libwebp
, libpng
, libcanberra
}:

stdenv.mkDerivation rec {
	pname = "rainlendar2";
	version = "2.24.1";

	src = fetchurl {
		url = "https://www.rainlendar.net/download/${version}/Rainlendar-Lite-${version}-amd64.tar.bz2";
		hash = "sha256-CSwN8kcKJkLatadsUCRTRfDfyAe8V8nD2MMmSrnvz9g=";
	};

	nativeBuildInputs = [
		autoPatchelfHook
		makeWrapper
	];

	buildInputs = [
		stdenv.cc.cc.lib
		gtk3
		glib
		cairo
		pango
		gdk-pixbuf
		atk
		libX11
		libXext
		libXrender
		libXinerama
		libXrandr
		libSM
		libICE
		libGL
		libxkbcommon
		fontconfig
		expat
		libwebp
		libpng
		libcanberra
	];

	installPhase = ''
		runHook preInstall

		mkdir -p $out/libexec/rainlendar2 $out/bin
		cp -r ./* $out/libexec/rainlendar2/

		makeWrapper $out/libexec/rainlendar2/rainlendar2 $out/bin/rainlendar2 \
			--chdir $out/libexec/rainlendar2

		runHook postInstall
	'';

	meta = with lib; {
		description = "Customizable desktop calendar";
		homepage = "https://www.rainlendar.net/";
		license = licenses.unfree;
		sourceProvenance = [ sourceTypes.binaryNativeCode ];
		platforms = [ "x86_64-linux" ];
		mainProgram = "rainlendar2";
	};
}
