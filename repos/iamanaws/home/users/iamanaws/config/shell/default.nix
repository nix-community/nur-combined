{ ... }:

{
  # Shell Aliases
  home.shellAliases = {
    # p="PATH=$PATH:$(pwd)";
    ls = "ls -F --color=auto";
    l = "ls -oshA";
    sl = "l";
    dir = "l";
    ".." = "cd ..";
    "..." = "cd ../..";
    cls = "clear";
    cl = "clear";
    t = "touch";
    md = "mkdir";
    "~" = "cd";
    w = "cat << EOF";
    hd = "head";
    tl = "tail";
    tt = "ttyper";

    ## Colorize the grep command output for ease use
    grep = "grep --color=auto";
    egrep = "egrep --color=auto";
    fgrep = "fgrep --color=auto";

    py = "python3";

    # Aliases for software managment
    # sudo nixos-rebuild switch --flake .#nixos
    #   --show-trace --option eval-cache false
    # nix-store --gc
    # nix-channel --update
    # sudo nix flake update
    # sudo nixos-rebuild switch --upgrade-all --flake .#nixos

    # nix-collect-garbage (nix-store -gc)
    # sudo nix-collect-garbage -d / --delete-old (nix-env --delete-generations old) (delete all execept current)
    # sudo nix-collect-garbage --delete-older-than 30d (nix-env --delete-generations 30d)
    # sudo nix-env --delete-generations +5 (keep the last 5 and newer than current)
    # sudo nixos-rebuild list-generations
    # nixos-rebuild switch --target-host user@host --use-remote-sudo --flake .#nixos --fast

    # nix-prefetch-url <uri> | nix-prefetch-url --unpack <uri>
    # nix hash convert --hash-algo sha256 $(nix-prefetch-url <uri>)
    # nix hash convert --hash-algo sha256 --from nix32 --to sri $(nix-prefetch-url <uri>)
    # journalctl -e --unit home-manager-iamanaws.service

    # Shutdown and Reboot
    ssn = "sudo shutdown now";
    sr = "sudo reboot";
  };
}
