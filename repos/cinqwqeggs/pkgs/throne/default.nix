{
  lib,
  stdenv,

  buildGoModule,
  fetchFromGitHub,
  fetchurl,
  makeDesktopItem,

  protobuf,
  protoc-gen-go,
  protorpc,

  cmake,
  copyDesktopItems,
  ninja,

  qt6Packages,

  # override if you want to have more up-to-date rulesets
  throne-srslist ? fetchurl {
    url = "https://raw.githubusercontent.com/throneproj/routeprofiles/60eb41122de3aa53c701ec948cd52d7a26adafea/srslist.h";
    hash = "sha256-k9vPtcusML4GR81UVeJ7jhuDHGk5Qh0eKw/cSOxBd5g=";
  },
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "throne";
  version = "1.0.13-unstable-2026-1-08";

  src = fetchFromGitHub {
    owner = "throneproj";
    repo = "Throne";
    rev = "43546383b11029c74fce8f30c8458552fb90b476";
    hash = "sha256-joTVj8z76dIWJycJEg1PVHQGcGRicEEt+Cv1vXu9kuc=";
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

  cmakeFlags = [
    # makes sure the app uses the user's config directory to store it's non-static content
    # it's essentially the same as always setting the -appdata flag when running the program
    (lib.cmakeBool "NKR_PACKAGE" true)
  ];

  patches = [
    # disable suid request as it cannot be applied to throne-core in nix store
    # and prompt users to use NixOS module instead. And use throne-core from PATH
    # to make use of security wrappers
    ./nixos-disable-setuid-request.patch
  ];

  postPatch = ''
    substituteInPlace src/global/Configs.cpp \
      --replace "QString path;" "path;"

  '';

  preBuild = ''
    ln -s ${throne-srslist} ./srslist.h
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 Throne -t "$out/share/throne/"
    install -Dm644 "$src/res/public/Throne.png" -t "$out/share/icons/hicolor/512x512/apps/"

    mkdir -p "$out/bin"
    ln -s "$out/share/throne/Throne" "$out/bin/"

    ln -s ${finalAttrs.passthru.core}/bin/Core "$out/share/throne/Core"

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

    postPatch = ''
      substituteInPlace server.go \
        --replace 'out.HasPrivilege = To(os.Geteuid() == 0)' \
                  'ret := false; if runtime.GOOS == "windows" || os.Geteuid() == 0 { ret = true } else if runtime.GOOS == "linux" { caps := unix.CapUserHeader{ Version: unix.LINUX_CAPABILITY_VERSION_3, Pid: 0 }; var data [2]unix.CapUserData; err := unix.Capget(&caps, &data[0]); if err == nil { ret = (data[0].Effective & (1 << unix.CAP_NET_ADMIN)) != 0 } }; out.HasPrivilege = To(ret)'

   
      substituteInPlace server.go --replace '"os"' '"os"
	"golang.org/x/sys/unix"'
    '';

    proxyVendor = true;
    vendorHash = "sha256-/0cnMlVcZyfOEhTclc6HpXLM8LNpMOQ4vhLLZyLHhvE=";

    nativeBuildInputs = [
      protobuf
      protoc-gen-go
      protorpc
    ];

    # taken from script/build_go.sh
    preBuild = ''
      pushd gen
      protoc -I . --go_out=. --protorpc_out=. libcore.proto
      popd
    '';

    # ldflags and tags are taken from script/build_go.sh
    ldflags = [
      "-w"
      "-s"
      "-X github.com/sagernet/sing-box/constant.Version=${finalAttrs.version}"
    ];

    tags = [
      "with_clash_api"
      "with_gvisor"
      "with_quic"
      "with_wireguard"
      "with_utls"
      "with_dhcp"
      "with_tailscale"
    ];
  };

  # this tricks nix-update into also updating the vendorHash of throne-core
  passthru.goModules = finalAttrs.passthru.core.goModules;

  meta = {
    description = "Qt based cross-platform GUI proxy configuration manager";
    homepage = "https://github.com/throneproj/Throne";
    license = lib.licenses.gpl3Plus;
    mainProgram = "Throne";
    maintainers = with lib.maintainers; [ "cinqwqeggs" ];
    platforms = lib.platforms.linux;
  };
})
