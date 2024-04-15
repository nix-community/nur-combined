{
  stdenv,
  fetchurl,
  perl,
  coreutils,
  gnugrep,
  nettools,
  procps,
}:
stdenv.mkDerivation {
  name = "collectl-4.3.1";
  src = fetchurl {
    url = "mirror://sourceforge/project/collectl/collectl/collectl-4.3.1/collectl-4.3.1.src.tar.gz";
    sha256 = "sha256-IYcmTZdLNqZTyKSwKKxu6rI+GIX4slY6M/BjWPOYifE=";
  };

  buildInputs = [perl];
  installPhase = ''
    sed -i -e "s@/usr/@/@" INSTALL
    export DESTDIR=$out
    ./INSTALL

    set -x
    sed -i -e "s@/usr/share/collectl@$out/share/collectl@" $out/bin/collectl

    sed -i -e 's@my $etcDir=sprintf("%s/etc", dirname(dirname($BinDir)));@my $etcDir=sprintf("%s/etc", dirname($BinDir));@' $out/bin/collectl
    sed -i -e 's@/bin/cat@${coreutils}/bin/cat@' $out/bin/collectl
    sed -i -e 's@/bin/hostname@${nettools}/bin/hostname@' $out/bin/collectl

    sed -i -e 's@/bin/grep@${gnugrep}/bin/grep@' $out/bin/collectl $out/etc/collectl.conf
    sed -i -e 's@/bin/egrep@${gnugrep}/bin/egrep@' $out/bin/collectl $out/etc/collectl.conf
    sed -i -e 's@/bin/ps@${procps}/bin/ps@' $out/bin/collectl $out/etc/collectl.conf
    sed -i -e 's|@ps=`ps axo pid,ppid,uid,comm,user`;|@ps=`${procps}/bin/ps axo pid,ppid,uid,comm,user`;|' $out/bin/collectl

    sed -i -e 's@$Host=`hostname`;@$Host=`${nettools}/bin/hostname`;@' $out/share/collectl/formatit.ph
    sed -i -e 's@last;@return;@' $out/share/collectl/formatit.ph
    set +x
  '';
  #collectl:$Rpm=          '/bin/rpm';
  #collectl:    $Lspci=(-e '/usr/sbin/lspci') ? '/usr/sbin/lspci' : '/usr/bin/lspci';
  #collectl:    if (!-e "/usr/sbin/lspci" && !-e "/usr/bin/lspci")
  #collectl:      pushmsg('W', "-sx disabled because 'lspci' not in $Lspci or '/usr/sbin' or '/usr/bin'");
  #collectl.conf:#Rpm =     /bin/rpm
  #collectl.conf:PQuery =   /usr/sbin/perfquery:/usr/bin/perfquery:/usr/local/ofed/bin/perfquery
  #collectl.conf:PCounter = /usr/mellanox/bin/get_pcounter
  #collectl.conf:VStat =    /usr/mellanox/bin/vstat:/usr/bin/vstat
  #collectl.conf:OfedInfo = /usr/bin/ofed_info:/usr/local/ofed/bin/ofed_info
  #collectl.conf:Resize=/usr/bin/resize:/usr/X11R6/bin/resize
  #collectl.conf:Ipmitool =  /usr/bin/ipmitool:/usr/local/bin/ipmitool:/opt/hptc/sbin/ipmitool
  #colmux:#!/usr/bin/perl -w
  #colmux:# development, assume collectl lives in /usr/bin.  The rest of the time use
  #colmux:my $BinDir=($0=~/pl$/) ? '/usr/bin' : dirname(abs_path($0));
  #colmux:my $Ping='/bin/ping';
  #colmux:my $ResizePath='/usr/bin/resize:/usr/X11R6/bin/resize';
  #colmux:my $Grep='/bin/grep';
  #colmux:my $Ssh='/usr/bin/ssh -o StrictHostKeyChecking=no -o BatchMode=yes';
  #colmux:  # /bin/ping should be installed natively with suid privs so we CAN use that.
  #colmux:  -colbin     path         use this path instead of /usr/bin/collectl for remote collectl
}
