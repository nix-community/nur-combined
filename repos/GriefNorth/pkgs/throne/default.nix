{
  lib,
  stdenv,

  buildGoModule,
  fetchFromGitHub,
  fetchurl,
  makeDesktopItem,

  protobuf,
  protoc-gen-go,
  protoc-gen-go-grpc,

  cmake,
  copyDesktopItems,
  ninja,

  qt6Packages,

  # override if you want to have more up-to-date rulesets
  throne-srslist ? fetchurl {
    url = "https://raw.githubusercontent.com/throneproj/routeprofiles/rule-set/srslist.h";
    hash = "sha256-xnyHF6baabFs1o/UWcMFtbXkhQULS0SM0BKlpSxx4aI=";
  },
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "throne";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "throneproj";
    repo = "Throne";
    tag = finalAttrs.version;
    hash = "sha256-qzQWUG4pAnNAtF/FmboNvj/XULCn+ww2ImG/d5DbR5w=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    ninja
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qttools
  ];

  env.INPUT_VERSION = finalAttrs.version;

  # suppress errors in 3rdparty/simple-protobuf
  env.NIX_CFLAGS_COMPILE = "-Wno-error=maybe-uninitialized";

  patches = [
    # disable suid request as it cannot be applied to ThroneCore in nix store
    # and prompt users to use NixOS module instead. And use ThroneCore from PATH
    # to make use of security wrappers
    ./nixos-disable-setuid-request.patch
    # fix nodiscard warnings with Qt >= 6.11 that are fatal with -Werror
    ./fix-utils-nodiscard.patch
  ];

  preBuild = ''
    ln -s ${throne-srslist} ./srslist.h
  '';

  # we'll wrap manually
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 Throne -t "$out/share/throne/"
    install -Dm644 "$src/res/public/Throne.png" -t "$out/share/icons/hicolor/512x512/apps/"

    makeQtWrapper "$out/share/throne/Throne" "$out/bin/Throne" \
      --append-flag "-appdata" # use writable config dir

    ln -s ${finalAttrs.passthru.core}/bin/ThroneCore "$out/share/throne/ThroneCore"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "throne";
      desktopName = "Throne";
      exec = "Throne";
      icon = "Throne";
      comment = finalAttrs.meta.description;
      terminal = false;
      categories = [ "Network" ];
    })
  ];

  passthru.core = buildGoModule {
    pname = "throne-core";
    inherit (finalAttrs) version src;
    sourceRoot = "${finalAttrs.src.name}/core/server";

    patches = [
      # also check cap_net_admin so we don't have to set suid
      ./core-also-check-capabilities.patch
      # relax parent directory check for NixOS security wrappers
      ./core-relax-parent-check.patch
    ];

    proxyVendor = true;
    vendorHash = "sha256-SiCFFE9q+Fi4RrMrB2QrEDX3Z8qVq4QwE1icPNqSzJg=";

    nativeBuildInputs = [
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
    ];

    # taken from script/build_go.sh
    preBuild = ''
      pushd gen
      protoc -I . --go_out=. --go-grpc_out=. libcore.proto
      popd

      VERSION_SINGBOX=$(go list -m -f '{{.Version}}' github.com/sagernet/sing-box)
      ldflags+=("-X 'github.com/sagernet/sing-box/constant.Version=$VERSION_SINGBOX'")
    '';

    # ldflags and tags are taken from script/build_go.sh
    ldflags = [
      "-w"
      "-s"
      "-X"
      "internal/godebug.defaultGODEBUG=multipathtcp=0"
      "-checklinkname=0"
    ];

    tags = [
      "with_clash_api"
      "with_gvisor"
      "with_quic"
      "with_wireguard"
      "with_utls"
      "with_dhcp"
      "with_tailscale"
      "badlinkname"
      "tfogo_checklinkname"
      "with_naive_outbound"
      "with_purego" # prebuilt .a files inside cronet-go are annoying to fix
    ];
  };

  # this tricks nix-update into also updating the vendorHash of passthru.core
  passthru.goModules = finalAttrs.passthru.core.goModules;

  meta = {
    description = "Qt based cross-platform GUI proxy configuration manager";
    homepage = "https://github.com/throneproj/Throne";
    license = lib.licenses.gpl3Plus;
    mainProgram = "Throne";
    maintainers = with lib.maintainers; [
      tomasajt
      aleksana
    ];
    platforms = lib.platforms.linux;
  };
})
