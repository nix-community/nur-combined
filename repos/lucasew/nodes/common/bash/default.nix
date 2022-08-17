{...}: {
  programs.bash = {
    shellAliases = {
      "la" = "ls -a";
      "cd.." = "cd ..";
      ".." = "cd ..";
      "simbora"="git add -A && git commit --amend && git push origin master -f";
    };
    promptInit = builtins.readFile ./promptInit.sh;
  };
}
