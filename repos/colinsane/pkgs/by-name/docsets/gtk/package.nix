{
  rtfm,
  runCommandLocal,
}:
# rtfm docset viewer actually ships Crystal and Gtk docsets (the latter of which includes several deps like Gdk, Pango, etc),
# so just extract those.
# N.B.: `rtfm` depends on `webkitgtk_6_0` -- costly!
# TODO: may be possible to set `buildTargets = [ "docsets" ]` to avoid the gui deps.
#   or just build the gtk docset more directly, since i'll want to build similar things like glib in the future too.
# N.B.: rtfm's docsets don't include Info.plist, but doesn't _seem_ to be a problem?
runCommandLocal "gtk.docset" { } ''
  mkdir -p $out/share/docsets
  cp -R ${rtfm}/share/rtfm/docsets/Gtk.docset $out/share/docsets/gtk.docset
''
