{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, makeWrapper
, libusb-compat-0_1
, coreutils
, gawk
, gnused
, gnugrep
, findutils
, bc
}:

stdenv.mkDerivation {
  pname = "aml-linux-usb-burn";
  version = "4.7.1-unstable-2018-05-30";

  src = fetchFromGitHub {
    owner = "Stane1983";
    repo = "aml-linux-usb-burn";
    rev = "d2283c7d4955249f60525e0e8fb674f86f8788f7";
    hash = "sha256-O/ePyEGebw/RpYCxi4rRHj+qyjWQOiuMdY63sLgftH4=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  # tools/update: 64 位动态链接，只需要 libusb-0.1.so.4 + libc
  # tools/aml_image_v2_packer: 32 位【静态链接】，不需要也不能 patchelf，autoPatchelfHook 会自动跳过
  buildInputs = [ libusb-compat-0_1 ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/aml-flash $out/bin $out/lib/udev/rules.d
    cp -r aml-flash tools $out/share/aml-flash/
    chmod +x $out/share/aml-flash/aml-flash \
             $out/share/aml-flash/tools/update \
             $out/share/aml-flash/tools/aml_image_v2_packer

    # 脚本用 dirname $0 定位 tools/（不跟随符号链接），
    # 所以 wrapper 必须指向 share 里的真实脚本，而不是 symlink
    makeWrapper $out/share/aml-flash/aml-flash $out/bin/aml-flash \
      --prefix PATH : ${lib.makeBinPath [ coreutils gawk gnused gnugrep findutils bc ]}

    cat > $out/lib/udev/rules.d/70-amlogic-usb-burn.rules <<'EOF'
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="1b8e", ATTR{idProduct}=="c003", MODE="0666", TAG+="uaccess"
    EOF

    runHook postInstall
  '';

  meta = {
    description = "Linux version of the Amlogic USB Burning Tool";
    homepage = "https://github.com/Stane1983/aml-linux-usb-burn";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "aml-flash";
  };
}
