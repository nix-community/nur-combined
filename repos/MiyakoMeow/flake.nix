{
  description = "MiyakoMeow's personal NUR repository";

  # NOTE: Keep in sync with substituters.toml (nixConfig does not support computed values)
  nixConfig = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
      "https://miyakomeow.cachix.org"
      "https://cache.garnix.io"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "miyakomeow.cachix.org-1:85k7pjjK1Voo+kMHJx8w3nT1rlBow3+4/M+LsAuMCRY="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

      filterDerivations =
        attrs:
        nixpkgs.lib.filterAttrs (name: value: nixpkgs.lib.isDerivation value) (
          builtins.removeAttrs attrs [
            "lib"
            "modules"
            "overlays"
          ]
        );

      # 为所有系统生成格式化工具
      formatterForAllSystems = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    in
    {
      # 使 formatter 对所有系统可用
      formatter = formatterForAllSystems;

      legacyPackages = forAllSystems (
        system:
        let
          basePkgs = import nixpkgs { inherit system; };
          # 从 overlays/default.nix 导入所有 overlays（自动应用所有定义的 overlay）
          overlaysSet = import ./overlays/default.nix;
          # 合并所有 overlays（自动应用所有在 overlays/default.nix 中定义的 overlay）
          allOverlays = nixpkgs.lib.composeManyExtensions (builtins.attrValues overlaysSet);
          pkgsWithOverlay = basePkgs.extend allOverlays;
        in
        import ./default.nix {
          pkgs = pkgsWithOverlay;
        }
      );

      packages = forAllSystems (system: filterDerivations self.legacyPackages.${system});

      # 可选：添加开发环境
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = [
            nixpkgs.legacyPackages.${system}.nixfmt-tree
          ];
        };
      });

      # 可选：添加检查
      checks = forAllSystems (
        system:
        let
          pkgs' = nixpkgs.legacyPackages.${system};
        in
        {
          format-check =
            pkgs'.runCommand "format-check"
              {
                nativeBuildInputs = [ pkgs'.nixfmt-tree ];
              }
              ''
                find ${self} -name "*.nix" -exec ${pkgs'.lib.getExe pkgs'.nixfmt} --check {} +
                touch $out
              '';
        }
      );
    };
}
