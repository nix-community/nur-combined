{
  imports = [ ./hmconvert.nix ];

  config.homeconfig.programs.readline = {
    enable = true;
    includeSystemConfig = false; # this is necessary
    variables = {
      # Be 8 bit clean.
      input-meta = true;
      output-meta = true;
      # To allow the use of 8bit-characters like the german umlauts, uncomment
      # the line below. However this makes the meta key not work as a meta key,
      # which is annoying to those which don't need to type in 8-bit characters.
      convert-meta = false;
      keyseq-timeout = 1000;
      # Display a list of the matching files
      show-all-if-ambiguous = true;
      # Perform partial completion on the first Tab press,
      # only start cycling full results on the second Tab press
      menu-complete-display-prefix = true;
      # Color files by types
      # Note that this may cause completion text blink in some terminals (e.g. xterm).
      colored-stats = true;
      # Append char to indicate type
      visible-stats = true;
      # Mark symlinked directories
      mark-symlinked-directories = true;
      # Color the common prefix
      colored-completion-prefix = true;
      # set show-mode-in-prompt on
      show-all-if-unmodified = true;

      echo-control-characters = false;

      # disable completion queries
      # https://superuser.com/questions/601992/how-can-i-disable-that-display-all-possibilities-and-more-stuff-in-bash
      completion-query-items = 0;
      page-completions = false;
    };

    extraConfig = ''

      TAB: menu-complete
      "\e[Z": menu-complete-backward

      # https://github.com/CMCDragonkai/.dotfiles-nixos/blob/master/.inputrc
      # Be more intelligent when autocompleting by also looking at the text after
      # the cursor. For example, when the current line is "cd ~/src/mozil", and
      # the cursor is on the "z", pressing Tab will not autocomplete it to "cd
      # ~/src/mozillail", but to "cd ~/src/mozilla". (This is supported by the
      # Readline used by Bash 4.)
      set skip-completed-text on

      # Immediately add a trailing slash when autocompleting directories or symlinks to directories
      set mark-directories on
      set mark-symlinked-directories on

      # Cycle through history based on characters already typed on the line
      "\e[A":history-search-backward
      "\e[B":history-search-forward

      set bell-style visible

      "\e\C-u": universal-argument
      "\e\C-Df": dump-functions
      "\e\C-Dm": dump-macros
      "\e\C-Dv": dump-variables

      $if Bash
        # Do history expansion on !$/!^/!!/!* when space is pressed
        Space: magic-space
       "\eu": "\C-ucd ..\C-j"
       "\el": "\C-uls\C-j"
       "\eL": "\C-uls -lah\C-j"
       "\ew": "\C-awatch \C-m"
       "\ee": "\C-aexec \C-e\C-m"
       "\eR": "\C-a\C-k reset\C-m"
       "\eh": "\C-e --help\C-m"
       "\ev": "\C-e --version\C-m"
       "\ep\ev": "\C-e --version\C-m"
       "\ep\ej": "\C-e|j\C-m"
       "\eT": "\C-a\C-kcd $(mktemp -d)\C-m"

       # apps
       "\epN": "\C-a\C-kncdu\C-m"
       "\eph": "\C-a\C-khtop\C-m"
       "\epd": "\C-a\C-kdool -N eth0 --bytes\C-m"
       "\et": "\C-a\C-ktree -l\C-m"
       "\eF": "\C-a\C-kfind -L\C-m"
       "\eG": "\C-a\C-kfd -j 1 -L\C-m"

       # nix stuff
       "\eo\en": "/nix/store/"
       "\eo\eN": "/nixfs/"

       # misc
       "\C-xs": "\C-asudo \C-e\C-m"
       "\epp": "\C-a\C-kpython\C-m"
       "\eop": "\C-a\C-kpython "
       "\eo\es": "\C-a\C-kssh "
       "\eod": "\C-a\C-kmkdir -p "
       "\em\em": "\C-a\C-kmake\C-m"
       "\em\eM": "\C-a\C-kmake -B\C-m"
       "\em\ec": "\C-a\C-kmake check VERBOSE=1\C-m"
       "\em\ei": "\C-a\C-kmake install\C-m"
       "\emt": "\C-a\C-kmake test\C-m"
       "\emh": "\C-a\C-kmake help\C-m"
       "\emr": "\C-a\C-kmake clean\C-m"
       "\em\er": "\C-a\C-kmake clean\C-m"
       "\emI": "\C-a\C-kmake install -j4\C-m"
       "\eM": "\C-a\C-kmake -B\C-m"
      $endif
    '';
  };
}
