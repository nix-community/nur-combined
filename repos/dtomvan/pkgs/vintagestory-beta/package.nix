{
  vintagestory,
  fetchzip,
  ...
}:
vintagestory.overrideAttrs rec {
  version = "1.22.0-rc.10";
  src = fetchzip {
    url = "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_${version}.tar.gz";
    hash = "sha256-aAHb7qxKMNvzjy+JAcw5jr1Vx2gArIEr9LUYfyIr4XI=";
  };
}
