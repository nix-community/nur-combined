{
  description = "MiyakoMeow's personal NUR repository";
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

      packages = forAllSystems (system: self.legacyPackages.${system});

      # 可选：添加开发环境
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = [
            nixpkgs.legacyPackages.${system}.nixfmt-tree
          ];
        };
      });

      # 可选：添加检查
      checks = forAllSystems (system: {
        format-check =
          nixpkgs.legacyPackages.${system}.runCommand "format-check"
            {
              nativeBuildInputs = [ nixpkgs.legacyPackages.${system}.nixfmt-tree ];
            }
            ''
              # 检查所有 .nix 文件是否格式正确
              find ${self} -name "*.nix" -exec nixfmt --check {} +
              touch $out
            '';
      });
    };
}
