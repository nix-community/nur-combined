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
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
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
