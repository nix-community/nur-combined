{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule rec {
  pname = "qbittorrent-clientblocker";
  version = "3.7";

  src = fetchFromGitHub {
    owner = "Simple-Tracker";
    repo = "qBittorrent-ClientBlocker";
    rev = version;
    hash = "sha256-XnH0lXk0fDmMNcebFOyWmT337a96SMavt9ZU9bJ3Smg=";
  };

  vendorHash = "sha256-18sSw19EJ3Xo8wFBjLXQBUyyB8FGmJAXVPYE95zh3dk=";

  ldflags = [
    "-s"
    "-w"
    "-X \"main.programVersion=${version}\""
  ];

  postInstall = ''
    mv $out/bin/qBittorrent-ClientBlocker $out/bin/${pname}

    mkdir -p $out/share/${pname}
    cp blockList.json $out/share/${pname}/blockList.json
    cp blockList-Optional.json $out/share/${pname}/blockList-Optional.json
    cp ipBlockList.txt $out/share/${pname}/ipBlockList.txt

    mkdir -p $out/share/doc/${pname}
    cp config.json $out/share/doc/${pname}/config.example.json
  '';

  meta = {
    description = "一款适用于 qBittorrent/Transmission (Beta)/BitComet (Beta, Partial) 的客户端屏蔽器, 默认屏蔽包括但不限于迅雷等客户端.  A client blocker compatible with qBittorrent/Transmission (Beta)/BitComet (Beta, Partial) which is prohibited to include but not limited to clients such as Xunlei";
    homepage = "https://github.com/Simple-Tracker/qBittorrent-ClientBlocker";
    license = lib.licenses.mit;
    mainProgram = pname;
  };
}
