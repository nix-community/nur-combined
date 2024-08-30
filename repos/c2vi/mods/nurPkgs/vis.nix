{ stdenv
, fetchFromGitHub
, ncurses
, cmake
, moreutils
, lib
, ftxui
}:

stdenv.mkDerivation rec {
	pname = "vis";
	version = "0.1.0";

	src = fetchFromGitHub {
		owner = "0xdeadbeer";
		repo = "vis";
    rev = "v${version}";
    sha256 = "sha256-Lf+xbAivGdGbrZ4y3I3b7hGS2mBQZ/hJ2zu9+4zluOg=";
	};

  # this package builds with ftxui from nixpkgs which is v5.0.0
  # so i choose to use that, otherwise the v3.0.0 specified in the CMakeLists.txt of the projects source
  # could be used like this
  localFtxui = fetchFromGitHub {
		owner = "ArthurSonzogni";
		repo = "ftxui";
    rev = "v3.0.0";
    sha256 = "sha256-2pCk4drYIprUKcjnrlX6WzPted7MUAp973EmAQX3RIE=";
  };

  cmakeFlags = [ "-DFETCHCONTENT_SOURCE_DIR_FTXUI=${ftxui.src}" ];

  nativeBuildInputs = [
    cmake
  ];
  
  buildInputs = [
    ncurses
    moreutils
    ftxui
  ];

  meta = with lib; {
    description = "Vi Scheduler (vis) is a simple TUI program built for managing your schedules in a calendar-like grid.";
    longDescription = ''
      Vi Scheduler (VIS) is a lightweight tool that brings a Vim-like calendar to your terminal. It allows you to quickly view and edit your schedule, appointments, and tasks without leaving your command-line interface.

      Built using C++ and the Ncurses library, vis offers a fast and efficient way to manage your time in the terminal. It suppors various navigation and editing commands inspired by Vim, such as navigating between days or months, adding and deleting events.
    '';
    homepage = "https://github.com/0xdeadbeer/vis";
    license = licenses.gpl3Only;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
