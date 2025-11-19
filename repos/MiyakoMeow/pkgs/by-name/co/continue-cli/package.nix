{
  lib,
  stdenv,
  nodejs,
  fetchurl,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "continue-cli";
  version = "1.5.14";

  src = fetchurl {
    url = "https://registry.npmjs.org/@continuedev/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha256-nb1S+ORL5MOFpabo6Yl8vRR8J6T8K2fMBYcN0p3Bxc8=";
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

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Continue CLI";
    homepage = "https://continue.dev";
    changelog = "https://changelog.continue.dev";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "cn";
    platforms = lib.platforms.all;
  };
})
