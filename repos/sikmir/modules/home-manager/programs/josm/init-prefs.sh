function initPrefs() {
  version=$1
  cfgfile=$2

  if [ ! -f $cfgfile ]; then
    $DRY_RUN_CMD mkdir -p $(dirname $cfgfile)
    $DRY_RUN_CMD eval "echo '<preferences/>' > $cfgfile"
    $DRY_RUN_CMD xml ed -P -L \
      -i "/preferences" -t attr -n "xmlns" -v "http://josm.openstreetmap.de/preferences-1.0" \
      -i "/preferences" -t attr -n "version" -v "$version" \
      $cfgfile
  else
    $DRY_RUN_CMD xml ed -P -L \
      -N N="http://josm.openstreetmap.de/preferences-1.0" \
      -u "/N:preferences/@version" -v "$version" \
      $cfgfile
  fi
}
