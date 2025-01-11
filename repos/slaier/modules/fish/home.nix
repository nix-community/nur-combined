{
  programs.fzf.enable = true;
  programs.fish = {
    enable = true;
    functions = {
      croc-send = {
        body = ''
          croc --relay local.lan send $argv 2>| while read -l line
            echo "$line"
            if string match -q -r -- 'CROC_SECRET' $line
              echo
              qrencode -t ansiutf8 -- (string trim $line)
            end
          end
        '';
        wraps = "croc";
      };
    };
  };
}
