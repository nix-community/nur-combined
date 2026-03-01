{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "bilibili_live_tui";
  version = "20230111";

  src = fetchFromGitHub {
    owner = "yaocccc";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-890sMPXtVo8Wzw8o9VIb5vAlGiLCXy+tFUwP8N7jzyU=";
  };

  vendorHash = "sha256-nUes0CEJ6kjQ/+nYkfarXfj82qAv0dVrDNGSGSlynHk=";
  subPackages = ["."];

  # 修复 go.mod 版本问题：依赖使用了 Go 1.18 泛型特性
  postPatch = ''
        substituteInPlace go.mod \
          --replace-fail 'go 1.15' 'go 1.18'

        # 删除 vendor 目录，让 Nix 重新获取依赖
        rm -rf vendor

        # 添加缺失的间接依赖到 go.mod
        cat >> go.mod <<EOF

    require (
    	github.com/gdamore/encoding v1.0.0 // indirect
    	github.com/golang/protobuf v1.5.2 // indirect
    	github.com/lucasb-eyer/go-colorful v1.2.0 // indirect
    	github.com/mattn/go-runewidth v0.0.13 // indirect
    	github.com/pkg/errors v0.9.1 // indirect
    	github.com/rivo/uniseg v0.4.2 // indirect
    	github.com/tidwall/match v1.1.1 // indirect
    	github.com/tidwall/pretty v1.2.0 // indirect
    	golang.org/x/sys v0.0.0-20220318055525-2edf467146b5 // indirect
    	golang.org/x/term v0.0.0-20210220032956-6a3ed077a48d // indirect
    	golang.org/x/text v0.3.7 // indirect
    )
    EOF
  '';

  ldflags = [
    "-w"
    "-s"
  ];

  postInstall = ''
    mv $out/bin/bili $out/bin/${pname}
  '';

  meta = with lib; {
    description = "终端下使用的bilibili弹幕获取和弹幕发送服务";
    homepage = "https://github.com/yaocccc/bilibili_live_tui";
    mainProgram = pname;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [fromSource];
  };
}
