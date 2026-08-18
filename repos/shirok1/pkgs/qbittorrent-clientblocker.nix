{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule (finalAttrs: {
  pname = "qbittorrent-clientblocker";
  version = "3.7";

  src = fetchFromGitHub {
    owner = "Simple-Tracker";
    repo = "qBittorrent-ClientBlocker";
    rev = finalAttrs.version;
    hash = "sha256-XnH0lXk0fDmMNcebFOyWmT337a96SMavt9ZU9bJ3Smg=";
  };

  vendorHash = "sha256-18sSw19EJ3Xo8wFBjLXQBUyyB8FGmJAXVPYE95zh3dk=";

  ldflags = [
    "-s"
    "-w"
    "-X \"main.programVersion=${finalAttrs.version}\""
  ];

  postInstall = ''
    mv $out/bin/qBittorrent-ClientBlocker $out/bin/${finalAttrs.pname}

    shareDir=$out/share/${finalAttrs.pname}
    mkdir -p $shareDir
    cp blockList.json $shareDir/blockList.json
    cp blockList-Optional.json $shareDir/blockList-Optional.json
    cp ipBlockList.txt $shareDir/ipBlockList.txt

    docDir=$out/share/doc/${finalAttrs.pname}
    mkdir -p $docDir
    cp config.json $docDir/config.example.json
  '';

  meta = {
    description = "一款适用于 qBittorrent/Transmission (Beta)/BitComet (Beta, Partial) 的客户端屏蔽器, 默认屏蔽包括但不限于迅雷等客户端.  A client blocker compatible with qBittorrent/Transmission (Beta)/BitComet (Beta, Partial) which is prohibited to include but not limited to clients such as Xunlei";
    homepage = "https://github.com/Simple-Tracker/qBittorrent-ClientBlocker";
    license = lib.licenses.mit;
    mainProgram = "qbittorrent-clientblocker";
  };
})
