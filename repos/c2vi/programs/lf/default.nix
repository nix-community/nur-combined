{ pkgs, self, confDir, system, inputs, ... }@params:
{
  home.file.".config/lf/icons".source = "${self}/programs/lf/icons";
	programs.lf = let

  myUeberzug = pkgs.ueberzugpp.overrideAttrs (prev: {
    src = pkgs.fetchFromGitHub {
      owner = "jstkdng";
      repo = "ueberzugpp";
      rev = "528fb0fd6719477308e779aa6dab6040faa698cc";
      hash = "sha256-VdfpWJOMlC4Ly2lDFvJ+BnOmaM71gLEaIkfwLqzAi/8=";
    };
    cmakeFlags = prev.cmakeFlags or [] ++ [ "-DENABLE_SWAY=ON" ];
  });

  oldpkgs = (builtins.getFlake "nixpkgs/release-25.05").legacyPackages.${system};
  mylf = oldpkgs.lf.overrideAttrs (final: prev: {
    patches = (prev.patches or [ ]) ++ [
      ./lf-filter.patch
    ];
    /*
    src = pkgs.fetchFromGitHub { # use the old v35 version of lf... so that my patch applies
      owner = "gokcehan";
      repo = "lf";
      rev = "r35";
      hash = "sha256-0ZyIbEKiQ9l30gqHlpW7l/6/TzqVRvnKk9c2FiQ6E6Y=";
    };
    */
    checkPhase = "";
  });

  myCleaner = pkgs.writeShellApplication {
    name = "myCleaner";

    runtimeInputs = with pkgs; [ myUeberzug ];

    text = ''
      ueberzugpp cmd -s "$UB_SOCKET" -a remove -i PREVIEW
      UB_PID=$(cat "$UB_PID_FILE")
      kill "$UB_PID"
    '';
  };

  myPreviewer = pkgs.writeShellApplication {
    name = "myPreviewer";
    runtimeInputs = with pkgs; [ 
      file
      gnumeric
      catdoc
      odt2txt
      transmission_4
      libcdio
      p7zip
      unrar
      xz
      bat # (text)
      exiftool
      ffmpegthumbnailer
      myUeberzug # (images, videos, pdf, fonts)
      ffmpegthumbnailer # (videos)
      exiftool # (metadata/audio, and file detection for .webm files)
      jq # (json and metadata)
      lynx # (html/web pages)
      poppler-utils # pdftoppm # (pdf)
      odt2txt # (odt)
      imagemagick # convert from imagemagick (fonts)
      atool # (archives)
      gnupg # (PGP encrypted files)
      man # (troff manuals)
      coreutils #busybox # other
    ];
    text = builtins.readFile "${self}/programs/lf/previewer";
  };

  mylfWrapper = pkgs.writeShellApplication {
      name = "lf";

      runtimeInputs = with pkgs; [ mylf myUeberzug util-linux ];

      text = ''

        # This is a wrapper script for lf that allows it to create image previews with
        # ueberzug. This works in concert with the lf configuration file and the
        # lf-cleaner script.

        set -e
        set +o nounset

        UB_PID=0
        UB_SOCKET=""

        case "$(uname -a)" in
            *Darwin*) UEBERZUG_TMP_DIR="$TMPDIR" ;;
            *) UEBERZUG_TMP_DIR="/tmp" ;;
        esac

        if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            ${mylf}/bin/lf "$@"
        else
            [ ! -d "$HOME/.cache/lf" ] && mkdir -p "$HOME/.cache/lf"
            UB_PID_FILE="$UEBERZUG_TMP_DIR/.$(uuidgen)"
            ueberzugpp layer --silent --no-stdin --use-escape-codes --pid-file "$UB_PID_FILE"
            UB_PID=$(cat "$UB_PID_FILE")
            UB_SOCKET="$UEBERZUG_TMP_DIR/ueberzugpp-''${UB_PID}.socket"
            export UB_PID UB_SOCKET

            ${mylf}/bin/lf "$@"
        fi
      '';
    };
  in
  {
    package = mylfWrapper // { inherit myUeberzug; };

		enable = true;
		commands = {
			dragon-out = ''%${pkgs.dragon-drop}/bin/xdragon -a -x "$fx"'';
			editor-open = ''$$EDITOR $f'';
			mkdir = ''
				''${{
				printf "Directory Name: "
				read DIR
				mkdir $DIR
				}}
			'';
      nav = ''
        %{{${pkgs.python3}/bin/python3 ${confDir}/scripts/nav/main.py --mode lf}}
      '';
      nav-home = ''
        %{{
          ${pkgs.python3}/bin/python3 ${confDir}/scripts/nav/main.py --mode lf --char H
        }}
      '';
      nav-work = ''
        %{{
          ${pkgs.python3}/bin/python3 ${confDir}/scripts/nav/main.py --mode lf --char W
        }}
      '';
		};
		settings = {
      icons = true;
			drawbox = true;
		};



		keybindings = {
      # sort by time
      mt = ":set sortby time; set info time; set reverse"; 
      # sort normally
      ms = ":set sortby natural; set info; set reverse!";
      F = "setfilter";
      P = "%pwd";
      W = "nav-work";
      H = "nav-home";
      n = "nav";
			"." = "set hidden!";
			"<enter>" = "open";
			do = "dragon-out";
			"gh" = "cd";
			"g/" = "/";
			ee = "editor-open";
			V = ''$${pkgs.bat}/bin/bat --paging=always --theme=gruvbox "$f"'';
		};
    extraConfig = ''
      %test $LF_LEVEL -eq 1 || >&2 printf "Warning: You're in a nested lf instance!"
      # export pid and ppid
      ''${{
          myPID=$(ps -j | grep lf | tail -n 1 | awk '{print $1}')
          myPGID=$(ps -j | grep lf | tail -n 1 | awk '{print $2}')
          lf -remote "send $id set user_pid $myPID"
          lf -remote "send $id set user_pgid $myPGID"
        }}

      source ${self}/programs/lf/opener
      set cleaner "${myCleaner}/bin/myCleaner"
      set cursorpreviewfmt "\033[7m"
      set previewer "${myPreviewer}/bin/myPreviewer"
      set period "1"

      #set promptfmt "
        #\033[48;2;35;38;39;38;2;28;220;156m  
        #\033[38;2;35;38;39;48;2;202;31;31m
        #\033[38;2;202;31;31;48;2;40;47;62m
        #\033[38;2;255;255;255m %w 
        #\033[38;2;40;47;62;48;2;58;67;89m
        #\033[38;2;255;255;255m %f 
        #\033[;38;2;58;67;89;49m\033[m"

      set timefmt "2023-11-28 15:04:05 "
      set waitmsg "\033[1;31m⏎\033[m"
      set tabstop 4
      set shellopts "-eu"
      set ifs "\n"
      set shell "bash"
      #set ruler "df:acc:progress:selection:filter:ind"
    '';
	};
}
