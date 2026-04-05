{
  lib,
  stdenvNoCC,
  fetchzip,
  zstd,
  copyInstallHook,
  renpy7BuildHook,
  renpyPackHook,
  renpy7WrapHook,
  makeDesktopItem,
  copyDesktopItems,
  resizeIcons,
  deleteUselessFiles,
  desktopToDarwinBundle,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "katawa-shoujo";
  version = "1.3.2";

  src = fetchzip {
    url = "https://cdn.fhs.sh/ks/bin/${finalAttrs.version}/%5B4ls%5D_katawa_shoujo_${finalAttrs.version}-%5Blinux-x86%5D%5BBA993979%5D.tar.zst";
    nativeBuildInputs = [ zstd ];
    hash = "sha256-R3gPKh2/AMMY1hvEw0swBNSwC2tHU/AIP144APrgPl4=";
  };

  nativeBuildInputs = [
    renpy7BuildHook
    copyInstallHook
    renpy7WrapHook
    copyDesktopItems
    renpyPackHook
    resizeIcons
    deleteUselessFiles
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isDarwin desktopToDarwinBundle;

  postPatch = ''
    cp ${./patch.rpy} game
  '';

  preInstall = ''
    rpatool -x game/data.rpa "$out/share/icons/hicolor/512x512/apps/katawa-shoujo.png=ui/icon.png"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "katawa-shoujo";
      desktopName = "Katawa Shoujo";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %U";
      icon = "katawa-shoujo";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Bishoujo-style visual novel by Four Leaf Studios, built in Ren'Py";
    longDescription = ''
      Katawa Shoujo is a bishoujo-style visual novel set in the fictional Yamaku High School for disabled children,
      located somewhere in modern Japan. Hisao Nakai, a normal boy living a normal life, has his life turned upside down
      when a congenital heart defect forces him to move to a new school after a long hospitalization. Despite his difficulties,
      Hisao is able to find friends—and perhaps love, if he plays his cards right. There are five main paths corresponding
      to the 5 main female characters, each path following the storyline pertaining to that character.

      The story is told through the perspective of the main character, using a first person narrative. The game uses a
      traditional text and sprite-based visual novel model with an ADV text box.

      Katawa Shoujo contains adult material, and was created using the Ren'Py scripting system. It is the product of an
      international team of amateur developers, and is available free of charge under the Creative Commons BY-NC-ND License.
    '';
    homepage = "https://www.katawa-shoujo.online";
    downloadPage = "https://www.katawa-shoujo.online/download";
    license = with lib.licenses; [ cc-by-nc-nd-30 ];
    maintainers = with lib.maintainers; [ ulysseszhan ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    # different from the executable name (katawa-shoujo) in nixpkgs when the game had not been removed there,
    # but the same as the original executable name set by the developer
    mainProgram = "Katawa Shoujo";
  };
})
