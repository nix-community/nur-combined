{
  programs.fzf.enable = true;
  programs.fish = {
    enable = true;
    functions = {
      croc-send = {
        body = ''
          croc --relay local.lan send $argv 2>| while read -l line
            echo "$line"
            if string match -q -r -- '^croc' $line
              echo
              qrencode -t ansiutf8 -- $line
            end
          end
        '';
        wraps = "croc";
      };
    };
  };
}
