{ fetchurl, fetchgit, stdenv, which, pkgconfig, makeWrapper, installShellFiles, libxcb, xcbutilkeysyms
, xcbutil, xcbutilwm, xcbutilxrm, libstartup_notification, libX11, pcre, libev
, yajl, xcb-util-cursor, perl, pango, perlPackages, libxkbcommon
, xorgserver, xvfb_run }:

let iconPatch = fetchgit {
  url = "https://aur.archlinux.org/i3-wm-iconpatch.git";
  rev = "695e3ad65c0579ddbc7bf71e3f4678bf3f2273f3";
  sha256 = "0b8h4ris0igbcchj1my4p854myaz7fpg84iq2ssg5qhi0nyyqczq";
};
in stdenv.mkDerivation rec {
  pname = "i3-icons";
  version = "4.18.3";

  src = fetchurl {
    url = "https://i3wm.org/downloads/i3-${version}.tar.bz2";
    sha256 = "03dijnwv2n8ak9jq59fhq0rc80m5wjc9d54fslqaivnnz81pkbjk";
  };

  nativeBuildInputs = [ which pkgconfig makeWrapper installShellFiles ];

  buildInputs = [
    libxcb xcbutilkeysyms xcbutil xcbutilwm xcbutilxrm libxkbcommon
    libstartup_notification libX11 pcre libev yajl xcb-util-cursor perl pango
    perlPackages.AnyEventI3 perlPackages.X11XCB perlPackages.IPCRun
    perlPackages.ExtUtilsPkgConfig perlPackages.InlineC
    xorgserver xvfb_run
  ];

  configureFlags = [ "--disable-builddir" ];

  enableParallelBuilding = true;

  patches = [ "${iconPatch}/iconsupport.patch" ];

  postPatch = ''
    patchShebangs .
  '';

  # Tests have been failing (at least for some people in some cases)
  # and have been disabled until someone wants to fix them. Some
  # initial digging uncovers that the tests call out to `git`, which
  # they shouldn't, and then even once that's fixed have some
  # perl-related errors later on. For more, see
  # https://github.com/NixOS/nixpkgs/issues/7957
  doCheck = false; # stdenv.hostPlatform.system == "x86_64-linux";

  checkPhase = stdenv.lib.optionalString (stdenv.hostPlatform.system == "x86_64-linux")
  ''
    (cd testcases && xvfb-run ./complete-run.pl -p 1 --keep-xserver-output)
    ! grep -q '^not ok' testcases/latest/complete-run.log
  '';

  postInstall = ''
    wrapProgram "$out/bin/i3-save-tree" --prefix PERL5LIB ":" "$PERL5LIB"
    for program in $out/bin/i3-sensible-*; do
      sed -i 's/which/command -v/' $program
    done

    installManPage man/*.1
  '';

  separateDebugInfo = true;

  meta = with stdenv.lib; {
    description = "A tiling window manager with titlebar icons";
    homepage    = "https://i3wm.org";
    maintainers = with maintainers; [ ];
    license     = licenses.bsd3;
    platforms   = platforms.all;

    longDescription = ''
      i3 is a tiling window manager primarily targeted at advanced users and
      developers. Based on a tree as data structure, supports tiling,
      stacking, and tabbing layouts, handled dynamically, as well as
      floating windows. Configured via plain text file. Multi-monitor.
      UTF-8 clean. This version of i3 has been patched
      to show icons in the title bars of windows
    '';
  };

}
