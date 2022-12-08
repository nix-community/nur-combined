{
  description = "tmux aware fuzzy finder. Offloads to rofi when not in a tmux session, otherwise uses fzf-tmux";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default =
        pkgs.writeShellApplication
          {
            name = "rzf";
            runtimeInputs = with pkgs; [ fzf rofi ];
            text = ''
              if [ "$TERM" == 'screen' ]; then
                fzf-tmux
              else
              	rofi -dmenu
              fi
            '';
          };
     };
}
