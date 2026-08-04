# Adapted from https://aur.archlinux.org/packages/wechat-universal-bwrap
# Original Maintainers: 7Ji <pugokushin at gmail dot com>, leaeasy <leaeasy at gmail dot com>
# Contributor: devome <evinedeng at hotmail dot com>
{
  lib,
  stdenv,
  wechat,
  bubblewrap,
  flatpak-xdg-utils,
}:

stdenv.mkDerivation {
  pname = "wechat-universal-bwrap";
  version = wechat.version;

  src = ./.;

  buildPhase = ''
    runHook preBuild
    gcc -shared -fPIC -o libuosdevicea.so libuosdevicea.c
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    local wechat_root="$out/libexec/wechat-universal"

    install -Dm755 libuosdevicea.so "$wechat_root/usr/lib/license/libuosdevicea.so"
    echo 'DISTRIB_ID=uos' | install -Dm644 /dev/stdin "$wechat_root/etc/lsb-release"

    install -Dm755 wechat-universal.sh "$wechat_root/common.sh"

    substituteInPlace "$wechat_root/common.sh" \
      --replace-fail "/{usr/lib/flatpak-xdg-utils,sandbox}/xdg-open" "${flatpak-xdg-utils}/bin/xdg-open /sandbox/xdg-open" \
      --replace-fail "/usr/lib/wechat-universal/common.sh" "$wechat_root/common.sh" \
      --replace-fail "/opt/wechat-universal{,}" "${wechat.src}/opt/wechat /opt/wechat-universal" \
      --replace-fail "{/usr/lib/wechat-universal,}/usr/lib/license" "$wechat_root/usr/lib/license /usr/lib/license" \
      --replace-fail "{/usr/lib/wechat-universal,}/etc/lsb-release" "$wechat_root/etc/lsb-release /etc/lsb-release" \
      --replace-fail "--ro-bind /usr{,}" "--ro-bind ${wechat.fhsenv}/usr /usr" \
      --replace-fail "--bind /usr/bin/{true,lsblk}" "" \
      --replace-fail "exec bwrap" "exec ${bubblewrap}/bin/bwrap" \
      --replace-fail "'start.sh'|'start'|'wechat-universal.sh'|'wechat-universal')" "'start.sh'|'start'|'wechat-universal.sh'|'wechat-universal'|'wechat')"

    mkdir -p $out/bin
    ln -s $wechat_root/common.sh $out/bin/wechat-universal
    ln -s $wechat_root/common.sh $out/bin/wechat
    ln -s $wechat_root/common.sh $out/bin/start.sh
    ln -s $wechat_root/common.sh $out/bin/stop.sh

    install -Dm644 wechat-universal.desktop $out/share/applications/wechat-universal.desktop
    substituteInPlace $out/share/applications/wechat-universal.desktop \
      --replace-fail "/usr/lib/wechat-universal" "$out/bin"
      
    install -Dm644 wechat-license $out/share/licenses/wechat-universal/wechat-license

    install -Dm644 ${wechat.src}/wechat.png $out/share/icons/hicolor/256x256/apps/wechat-universal.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "WeChat (Universal) with bwrap sandbox (adapted from AUR)";
    homepage = "https://linux.weixin.qq.com/";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "wechat-universal";
  };
}
