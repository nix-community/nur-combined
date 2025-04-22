{ lib
, squashfs-tools
, fetchurl
, freetz
, targetEndianness ? "LE"
}:

assert (targetEndianness == "LE" || targetEndianness == "BE");

squashfs-tools.overrideAttrs (oldAttrs: rec {
  pname = "squashfs-tools-avm-${lib.strings.toLower targetEndianness}";
  # patches fail with squashfs-tools 4.6.1
  # freetz-ng/make/host-tools/squashfs4-le-host/squashfs4-le-host.mk
  # $(call TOOLS_INIT, 4.3)
  version = "4.3";

  # version 4.3 is not tagged on github
  src = fetchurl {
    url = "mirror://sourceforge/project/squashfs/squashfs/squashfs${version}/squashfs${version}.tar.gz";
    hash = "sha256-DWBVEkN7HrgAtHNnkVWSle5fYBd+EC5NTM0O4kGl8/Y=";
  };

  # 4k-align.patch requires version 4.6.1
  patches = [];

  # no diff between "be" and "le":
  # cd freetz-ng && diff -r make/host-tools/squashfs4-{be,le}-host/patches
  postPatch = (oldAttrs.postPatch or "") + ''
    for p in ${freetz.src}/make/host-tools/squashfs4-le-host/patches/*.patch; do
      patch -p0 < $p
    done
  '';

  makeFlags = (oldAttrs.makeFlags or []) ++ [
    # no effect? squashfs2 and squashfs3 tools are not built
    "LEGACY_FORMATS_SUPPORT=1"
  ];

  preConfigure = ''
    makeFlagsArray+=('EXTRA_CFLAGS=-fcommon -DTARGET_FORMAT=AVM_${targetEndianness}')
  '';

  postInstall = ''
    for f in $out/bin/*; do
      mv -v $f ''${f}4-avm-${lib.strings.toLower targetEndianness}
      ln -v -s -r ''${f}4-avm-${lib.strings.toLower targetEndianness} ''${f}-avm-${lib.strings.toLower targetEndianness}
    done
  '';
})
