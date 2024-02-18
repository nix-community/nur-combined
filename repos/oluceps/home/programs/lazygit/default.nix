{ pkgs, ... }:
{
  home.packages = [ pkgs.lazygit ];
  xdg.configFile."lazygit/config.yml".text = ''
    os:
      edit: 'hx {{filename}}'
      editAtLine: 'hx {{filename}}:{{line}}'
      editAtLineAndWait: 'hx {{filename}}:{{line}}'
      editInTerminal: true
    # git:
    #   commit:
    #     signOff: true
  '';
}
