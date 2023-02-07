{ stdenv, fetchurl, rpm, cpio, lib }:
let
  version = "10.2.835-1";
  name = "netextender";
  pname = "netextender";
  meta = with lib; {
    description = "";
    platforms = platforms.unix;
    license = licenses.unfree;
    broken = true;
  };

in stdenv.mkDerivation {
  inherit version name pname meta;

  src = fetchurl {
    name = "netextender.rpm";
    url =
      "https://software.sonicwall.com/NetExtender/NetExtender.Linux-${version}.x86.64.rpm";
    sha256 = "09w67racskg13y0zf6jwc1g9rq6drkcqhbx5f50kxgr74w31j11h";
  };

  nativeBuildInputs = [ rpm cpio ];
  buildInputs = [ ];

  buildCommand = ''
    mkdir -p $out/
    cd $out
    rpm2cpio $src | cpio -idv -f "*uninstallNetExtender"
    mv $out/usr/* $out/
    rmdir $out/usr
    patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/sbin/netExtender
    for i in ip-up.d ip-down.d ipv6-up.d ipv6-down.d
    do
        mkdir -p $out/etc/ppp/$i
    done
    mkdir -p $out/etc/ppp/ip-up.d
    mkdir -p $out/etc/ppp/ip-down.d

    touch $out/etc/ppp/ip-down.d/sslvpnroutecleanup
    touch $out/etc/ppp/ipv6-down.d/sslvpnroute6cleanup
    chmod 700 $out/etc/ppp/ip-down.d/sslvpnroutecleanup
    chmod 700 $out/etc/ppp/ipv6-down.d/sslvpnroute6cleanup

    mv $out/etc $out/etc-skeleton
    mkdir -p $out/etc
    ln -s /host/tmp/netextender-chroot/ppp $out/etc/ppp
  '';
}
