# default.nix for sliver
{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "sliver";
  version = "1.5.43";
  clientSrc = fetchurl {
    url = "https://github.com/BishopFox/sliver/releases/download/v${version}/sliver-client_linux";
    sha256 = "sha256-30m/U3RyU8OC3lRP308v0XtYaswXy4HPTEFoxTUyJgk=";
  };

  serverSrc = fetchurl {
    url = "https://github.com/BishopFox/sliver/releases/download/v${version}/sliver-server_linux";
    sha256 = "sha256-iHO0XRru8Yg6j4DgqlDeRf5sXwtub2jLXjZb9ygcSz8=";
  };

  dontBuild = true;
  dontUnpack = true;
  # 安装阶段：将二进制文件复制到 $out/bin 目录下
  installPhase = ''
    mkdir -p $out/bin

    # 复制客户端并重命名为 sliver-client
    cp ${clientSrc} $out/bin/sliver-client
    chmod +x $out/bin/sliver-client

    # 复制服务器并重命名为 sliver-server
    cp ${serverSrc} $out/bin/sliver-server
    chmod +x $out/bin/sliver-server
  '';

  meta = with lib; {
    description = "Adversary Emulation Framework";
    homepage = "https://github.com/BishopFox/sliver";
    license = licenses.gpl3;
    maintainers = with maintainers; [ "KongJian520" ];
    mainProgram = "sliver-server";
  };
}
