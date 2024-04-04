
{ lib
, stdenv
, fetchFromGitHub
, meson
, pkg-config
, inih
, systemd
, scdoc
, ninja
, pkgs
, alacritty
}:

stdenv.mkDerivation rec {
  pname = "xdg-desktop-portal-termfilechooser";
  version = "0.0.0";

	src = fetchFromGitHub {
   	owner = "GermainZ";
   	repo = "xdg-desktop-portal-termfilechooser";
    	rev = "71dc7ab06751e51de392b9a7af2b50018e40e062";
   	hash = "sha256-645hoLhQNncqfLKcYCgWLbSrTRUNELh6EAdgUVq3ypM=";
	};

  #doCheck = true;
  #doUnpack = true;

  #passthru.tests.version =
    #testVersion { package = hello; };

	nativeBuildInputs = [
		meson
		pkg-config
		inih
		systemd
		scdoc
		ninja
	];

	buildInputs = [
		systemd
	];

	patches = [
		./xdg-desktop-portal-termfilechooser-add-x11.patch
		./test.patch
		./test2.patch
		./meson-build.patch
		./lf-wrapper.patch

	];

	mesonFlags = [
   	"-Dsd-bus-provider=libsystemd"
	];

	installPhase = ''
		ninja install
	'';

	postConfigure = ''
   	substituteInPlace ../src/core/config.c --replace '#define FILECHOOSER_DEFAULT_CMD "/usr/share/xdg-desktop-portal-termfilechooser/ranger-wrapper.sh"' '#define FILECHOOSER_DEFAULT_CMD "${placeholder "out"}/share/xdg-desktop-portal-termfilechooser/lf-wrapper.sh"'

		ls ../contrib
   	substituteInPlace ../contrib/lf-wrapper.sh --replace '#CCCMMMDDD' '${alacritty}/bin/alacritty'

		echo "###### start"
		cat ../src/core/config.c
		echo "###### end"

	'';
		#exit 1
   	#substituteInPlace ../src/core/config.c --replace '#define FILECHOOSER_DEFAULT_DIR "/tmp"' '#define FILECHOOSER_DEFAULT_DIR "${placeholder "out"}/share/xdg-desktop-portal/portals/termfilechooser.portal"'

  meta = with lib; {
    description = "A xdg portal, that let's you use your favourite terminal file chooser to choose files acroos all applications";
    longDescription = "A long description";
    homepage = "https://github.com/GermainZ/xdg-desktop-portal-termfilechooser";
    license = licenses.mit;
    maintainers = [ maintainers.eelco ];
    platforms = platforms.all;
  };
}


