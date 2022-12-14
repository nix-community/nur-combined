{ ... }: {
  subcommands.ansible = {
    allowExtraArguments = true;
    description = "Run ansible in dotfiles folder";
    action.bash = ''
      cd ~/.dotfiles
      nix build $(realpath ~/.dotfiles)#pkgs.ansible --out-link /tmp/ansible-result
      /tmp/ansible-result/bin/ansible "$@"
    '';
  };
  subcommands.ansible-playbook = {
    allowExtraArguments = true;
    description = "Run ansible-playbook in dotfiles folder";
    action.bash = ''
      cd ~/.dotfiles
      nix build $(realpath ~/.dotfiles)#pkgs.ansible --out-link /tmp/ansible-result
      /tmp/ansible-result/bin/ansible-playbook "$@"
    '';
  };
}
