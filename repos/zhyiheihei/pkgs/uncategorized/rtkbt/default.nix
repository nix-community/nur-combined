{
  lib,
  stdenv,
  fetchFromGitHub,
}:
let
  src = fetchFromGitHub {
    owner = "radxa";
    repo = "rtkbt";
    rev = "72ef9b75374fdde945e0a19f6aba68e13d4d426d";
    hash = "sha256-iySsJdl3o/QwlpcH7IC7hj76sm9IdLc/r8tOeP4yExQ=";
  };

  # Radxa/Realtek ship these without a separate licence file. The driver is
  # GPL, the firmware blobs are redistributable-but-closed, so the pin above
  # stays explicit rather than tracking a moving branch.
  firmware = "${src}/rtkbt-firmware/lib/firmware/rtlbt";
in
stdenv.mkDerivation {
  pname = "rtkbt";
  version = "2022-06-07";

  inherit src;
  sourceRoot = "${src.name}/uart/rtk_hciattach";

  # Upstream ships no install target.
  installPhase = ''
    runHook preInstall
    install -Dm755 rtk_hciattach $out/bin/rtk_hciattach
    runHook postInstall
  '';

  # The firmware path is compiled in; keep it inside the store instead of the
  # FHS /lib/firmware, which does not exist on NixOS.
  postPatch = ''
    substituteInPlace rtb_fwc.c \
      --replace-fail '"/lib/firmware/rtlbt/"' '"${placeholder "out"}/lib/firmware/rtlbt/"'
  '';

  postInstall = ''
    install -Dm644 ${firmware}/rtl8852bs_fw $out/lib/firmware/rtlbt/rtl8852bs_fw
    install -Dm644 ${firmware}/rtl8852bs_config $out/lib/firmware/rtlbt/rtl8852bs_config
  '';

  meta = {
    description = "Realtek Bluetooth UART attach tool and RTL8852BS firmware";
    homepage = "https://github.com/radxa/rtkbt";
    license = lib.licenses.unfreeRedistributableFirmware;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    platforms = lib.platforms.linux;
  };
}
