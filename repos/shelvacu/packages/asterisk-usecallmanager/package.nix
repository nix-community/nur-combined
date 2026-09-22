# Asterisk with the usecallmanager.nz patch, which reintroduces chan_sip and
# teaches it the proprietary SIP that Cisco's *enterprise* (Unified CM) phone
# firmware speaks: the softkeys, BLF, call park, DND/call-forward sync and
# conferencing that stock Asterisk leaves dead on an 8851.
#
# It is a large patch -- 96 files, 77 of them new -- and nearly all of chan_sip
# arrives with it, because upstream removed chan_sip in Asterisk 21. So a phone
# that wants these features has to be a chan_sip peer in sip.conf; chan_pjsip
# cannot serve it. See docs/pbxvm.md for how the two channel drivers divide the
# ports here.
{
  lib,
  asterisk,
  fetchurl,
}:
let
  # The patch is cut against one exact Asterisk release and will not apply to
  # another, so pin both and fail loudly on a nixpkgs bump rather than silently
  # building an unpatched asterisk under a patched name.
  version = "22.8.2";

  # Pinned to a commit rather than master: the file at master is mutable, and a
  # silent change to a 1.4 MB patch is not something to discover at deploy time.
  patch = fetchurl {
    url =
      "https://raw.githubusercontent.com/usecallmanagernz/patches/"
      + "259fdf79a7fdd56d69fe5a12fdf385f7fd31fd12/asterisk/cisco-usecallmanager-${version}.patch";
    hash = "sha256-N0pwqj84KV2HIVNRo/iDt2nyVKIIPHHqMGTnEPIkC1E=";
  };
in
lib.throwIf (asterisk.version != version)
  ''
    asterisk-usecallmanager: nixpkgs now has asterisk ${asterisk.version}, but the
    pinned usecallmanager patch is for ${version}. Patches for other releases are at
    https://github.com/usecallmanagernz/patches/tree/master/asterisk -- update the
    version, url and hash together.
  ''
  (
    asterisk.overrideAttrs (old: {
      pname = "asterisk-usecallmanager";
      # Appended, so it lands after nixpkgs' own runtime-vardirs and opus
      # patches. Verified to apply cleanly in that order.
      patches = (old.patches or [ ]) ++ [ patch ];
    })
  )
