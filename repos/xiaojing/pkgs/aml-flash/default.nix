# Amlogic USB 烧录工具（Amlogic USB Burning Tool 的 Linux 命令行版）
# 用于给 S905/S912 等 Amlogic 芯片的盒子/开发板刷机
{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, libusb-compat-0_1
}:

stdenv.mkDerivation {
  pname = "aml-flash";
  version = "unstable-2023-08-29";

  src = fetchFromGitHub {
    owner = "Stane1983";
    repo = "aml-linux-usb-burn";
    rev = "257b808ba8550db023875b139db2eca9d11d55a4";
    hash = "sha256-pYr1wLHVDc1oEkRT+D625guyM1oTvXw65Am1FIpgH5Y=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ libusb-compat-0_1 ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec/aml-flash
    cp -r tools $out/libexec/aml-flash/tools
    install -Dm755 aml-flash $out/libexec/aml-flash/aml-flash

    # 脚本通过 "$(dirname $0)/tools/..." 定位辅助二进制。
    # 由于脚本会被符号链接到 $out/bin，dirname $0 会解析错位置，
    # 这里直接把工具路径硬编码为 store 路径。
    substituteInPlace $out/libexec/aml-flash/aml-flash \
      --replace 'TOOL_PATH="$(cd $(dirname $0); pwd)"' \
                 'TOOL_PATH="'"$out"'/libexec/aml-flash"'

    ln -s $out/libexec/aml-flash/aml-flash $out/bin/aml-flash

    runHook postInstall
  '';

  postInstall = ''
    mkdir -p $out/lib/udev/rules.d
    cat > $out/lib/udev/rules.d/70-amlogic-usb.rules <<'EOF'
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="1b8e", ATTR{idProduct}=="c003", MODE:="0666", SYMLINK+="worldcup"
EOF
  '';

  meta = {
    description = "Linux command-line version of the Amlogic USB Burning Tool, for flashing Amlogic SoC boards (S905/S905X/S912/A113/T962/...) over USB";
    homepage = "https://github.com/Stane1983/aml-linux-usb-burn";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ fromSource binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "aml-flash";
    maintainers = [ ];
  };
}
