{
  stdenv,
  writeShellScript,
  mupen64plus,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
  fetchurl,
}:
{
  name, # The name of the executable.
  desktopName, # The name displayed in the "applications" menu.
  category ? "Emulator",
  # The freedesktop.org additional category.
  # Can be any additional category where the "related category" is "Game". Defaults to "Emulator".
  # See https://specifications.freedesktop.org/menu-spec/latest/apas02.html
  icon ? {
    # Attribute set passed to makeDesktopIcon, minus the 'name" attribute:
    src = fetchurl {
      url = "https://1000logos.net/wp-content/uploads/2017/07/Color-N64-Logo-500x393.jpg";
      sha256 = "01hnfbrrgvb560m14hq4nwirhngl8mss6s6wmbl56bl7jnngzpig";
    };
  },
  rom, # Run-time path to the N64 ROM file.
}:
let
  wrapper = writeShellScript "mupen64plus-wrapper" ''
    ${mupen64plus}/bin/mupen64plus "${rom}"
  '';
in
stdenv.mkDerivation rec {
  pname = "${name}-mupen64plus-wrapper";
  version = "1.1.0";
  src = mupen64plus; # Dummy src; It's not used.
  dontUnpack = true;
  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ln -s ${wrapper} $out/bin/${name}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      inherit desktopName;
      name = pname;
      exec = name;
      icon = name;
      categories = [
        "Game"
        category
      ];
    })
  ];

  desktopIcon = makeDesktopIcon ({ inherit name; } // icon);
}
