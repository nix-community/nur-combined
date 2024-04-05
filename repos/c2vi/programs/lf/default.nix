{ pkgs, self, confDir, system, inputs, ... }@params:
{
  home.file.".config/lf/icons".source = "${self}/programs/lf/icons";
	programs.lf = let
  mylf = pkgs.lf.overrideAttrs (final: prev: {
    patches = (prev.patches or [ ]) ++ [
      ./lf-filter.patch
    ];
    checkPhase = "";
  });
  myPreviewer = pkgs.writeShellApplication {
    name = "myPreviewer";
    runtimeInputs = with pkgs; [ 
      file
      bat # (text)
      ueberzug # (images, videos, pdf, fonts)
      ffmpegthumbnailer # (videos)
      exiftool # (metadata/audio, and file detection for .webm files)
      jq # (json and metadata)
      lynx # (html/web pages)
      poppler_utils # pdftoppm # (pdf)
      odt2txt # (odt)
      imagemagick # convert from imagemagick (fonts)
      atool # (archives)
      gnupg # (PGP encrypted files)
      man # (troff manuals)
      coreutils #busybox # other
    ];
    text = builtins.readFile "${self}/programs/lf/previewer";
  };
  # use newest version of ueberzug from nixpkgs unstable because: https://github.com/ueber-devel/ueberzug/issues/15
  # mylfWrapper = let myUeberzug = inputs.nixpkgs-unstable.legacyPackages.${system}.ueberzug;
  mylfWrapper = let myUeberzug = pkgs.ueberzug.overrideAttrs (final: prev: { version = "18.2.2"; });
    in pkgs.writeShellApplication {
      name = "lf";

      #runtimeInputs = with pkgs; [ curl w3m ];

      text = ''
        # got it FROM: https://codeberg.org/tplasdio/lf-config/src/branch/main/.local/bin/lfub


        # Envolvedor de lf, que permite crear previsualizaciones de imágenes
        # con ueberzug, en conjunto con mi configuración 'previewer' y 'cleaner' para lf
        # Taken from: https://github.com/LukeSmithxyz/voidrice/blob/master/.local/bin/lfub
        # TODO:
        # - Capturar cuando se cierre/mate la ventana conteniendo la terminal que corre
        #	este script, pues si no se quedarán procesos huérfanos 'lf' 'lfub' 'ueberzug'

        set -e
        set +u
        : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"

        cleanup() {
          exec 3>&-
          # FIXME:
          # after SIGINT commands that expected some arguments, previews for that directory
          # are stuck in "loading", because there's no fifo file to remove or something
          # Example:
          # gpg -d  # ← Forgot to type $f for decrypting a file
          # Ctrl-C  # ← Back to lf, previews are stuck
          rm "$FIFO_UEBERZUG"
        }

        main() {
          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            ${mylf}/bin/lf "$@"
          else
            [ -d "''${XDG_CACHE_HOME}/lf" ] || mkdir -p "''${XDG_CACHE_HOME}/lf"
            export FIFO_UEBERZUG="''${XDG_CACHE_HOME}/lf/ueberzug-$$"
            mkfifo "$FIFO_UEBERZUG"
            ${myUeberzug}/bin/ueberzug layer -s < "$FIFO_UEBERZUG" -p json &
            exec 3> "$FIFO_UEBERZUG"
            trap cleanup HUP INT QUIT TERM PWR EXIT
            ${mylf}/bin/lf "$@" 3>&-
          fi
        }

        main "$@" || exit $?
      '';
    };
  in
  {
    package = mylfWrapper;

		enable = true;
		commands = {
			dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
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
      set cleaner "${self}/programs/lf/cleaner"
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
      set ruler "df:acc:progress:selection:filter:ind"
    '';
	};
}
