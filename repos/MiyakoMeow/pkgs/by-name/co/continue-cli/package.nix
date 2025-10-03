{
  lib,
  stdenv,
  nodejs,
  fetchurl,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "continue-cli";
  version = "1.4.45";

  src = fetchurl {
    url = "https://registry.npmjs.org/@continuedev/cli/-/cli-${version}.tgz";
    hash = "sha512-TKjBVK70/sumsKLFdXE5VaeMT5KS7dmDVH7eSGXegj+z2dX7Pe5FpZWr8qfUIhm2veR3Pz4ltTFBxW0YuEY7uQ==";
  };

  nativeBuildInputs = [ nodejs ];

  unpackPhase = ''
    mkdir -p $out/lib
    cd $out/lib
    tar -xzf $src
  '';

  installPhase = ''
    # 安装包到 lib 目录
    mkdir -p $out/lib/node_modules/@continuedev
    mv $out/lib/package $out/lib/node_modules/@continuedev/cli

    # 创建二进制文件包装脚本
    mkdir -p $out/bin
    cat > $out/bin/cn <<EOF
    #!/bin/sh
    exec ${nodejs}/bin/node $out/lib/node_modules/@continuedev/cli/dist/cn.js "\$@"
    EOF
    chmod +x $out/bin/cn
  '';

  meta = {
    description = "Continue CLI";
    homepage = "https://continue.dev";
    license = lib.licenses.asl20; # Apache-2.0
    maintainers = with lib.maintainers; [ ];
    mainProgram = "cn";
    platforms = lib.platforms.all;
  };
}
