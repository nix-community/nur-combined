{
  vintagestory,
  fetchzip,
  dotnet-runtime_10,
  ...
}:
(vintagestory.override {
  dotnet-runtime_8 = dotnet-runtime_10;
}).overrideAttrs
  rec {
    version = "1.22.0-rc.1";
    src = fetchzip {
      url = "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_${version}.tar.gz";
      hash = "sha256-CvUwO6WSZNSLG6jG6AESV6DaxOAEzfBSVNAlvZqD6vk=";
    };
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/vintagestory $out/bin $out/share/pixmaps $out/share/fonts/truetype
      cp -r * $out/share/vintagestory
      cp $out/share/vintagestory/assets/gameicon.png $out/share/pixmaps/vintagestory.png
      cp $out/share/vintagestory/assets/game/fonts/*.ttf $out/share/fonts/truetype

      runHook postInstall
    '';
  }
