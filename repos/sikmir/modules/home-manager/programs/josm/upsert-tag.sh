function upsertTag() {
  key=$1
  value=$2
  cfgfile=$3

  if [ -f $cfgfile ]; then
    $DRY_RUN_CMD xml ed -P -L \
      -N N="http://josm.openstreetmap.de/preferences-1.0" \
      -d "//N:tag[@key='$key']" \
      -s '/N:preferences' -t elem -n "tag" \
      -i '$prev' -t attr -n "key" -v "$key" \
      -a "/N:preferences/tag[@key='$key']" -t attr -n "value" -v "$value" \
      $cfgfile
  fi
}
