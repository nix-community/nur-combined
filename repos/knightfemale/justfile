# 查看输出
show:
    nix flake show .

# 构建 package
build-package *args:
    nom build .#packages.{{args}}

# 构建 legacyPackage
build-legacyPackage *args:
    nom build .#legacyPackages.{{args}}

# 更新
update *args: 
    nix flake update {{args}}

# 格式化
format:
    treefmt .
