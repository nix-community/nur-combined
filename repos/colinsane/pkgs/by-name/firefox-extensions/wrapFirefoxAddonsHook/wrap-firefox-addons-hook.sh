patchManifest() {
  local m=$1

  echo "patching manifest at $m to use extid $extid"
  local newManifest=$(@jq@ '. + {"applications": { "gecko": { "id": "'"$extid"'" }}, "browser_specific_settings":{"gecko":{"id": "'"$extid"'"}}}' "$m")
  echo "$newManifest" > "$m"

  echo "updating permissions for $m"
  echo "  old perms: $(@jq@ '.permissions' "$m")"

  # if the user omits any specification, then keep all perms
  # N.B.: `${X:-Y}` defaults to Y only if X is unset -- not if X is set but falsey.
  # this allows the user to remove all perms by setting `keepFirefoxPermissions=`.
  local keepPerms=${keepFirefoxPermissions:-.*}
  # allow permissions to be specified as either regex OR literal
  local jqKeepPermsRegexChoices=$(concatStringsSep '|' keepPerms)
  local permsFromRegex=$(@jq@ '.permissions | map(select(test("^('"$jqKeepPermsRegexChoices"')$")))' "$m")
  local jqKeepPermsArray='["'"$(concatStringsSep '", "' keepPerms)"'"]'
  local permsFromLit=$(@jq@ ".permissions - (.permissions - $jqKeepPermsArray)" "$m")
  local newPerms=$(@jq@ -n "$permsFromRegex + $permsFromLit | unique")

  local newManifest=$(@jq@ '.permissions = '"$newPerms" "$m")
  echo "$newManifest" > "$m"
  echo "  new perms: $(@jq@ '.permissions' "$m")"
}

fixupFirefoxAddon() {
  local xpiPath=$1

  local unpacked=$(mktemp -d)

  # unpack the addon
  echo "unpacking $xpiPath to $unpacked"
  @unzip@ -q "$xpiPath" -d "$unpacked"

  # patch the .xpi
  # firefox requires addons to have an id field when sideloading:
  # - <https://extensionworkshop.com/documentation/publish/distribute-sideloading/>
  for m in manifest.json manifest_v2.json manifest_v3.json; do
    if [ -e "$unpacked/$m" ]; then
      patchManifest "$unpacked/$m"
    fi
  done

  # repack the addon
  echo "repacking $unpacked into $xpiPath XPI"
  # change dir so as to pack into the toplevel
  (cd "$unpacked"; @zip@ -r -q -FS "$xpiPath" .)
  @strip_nondeterminism@ "$xpiPath"
}

fixupFirefoxAddons() {
  # crawl the output for .xpi files to fixup
  for xpi in $(@find@ "$out" -name '*.xpi'); do
    fixupFirefoxAddon "$xpi"
  done
}

if [ -z "${dontFixupFirefoxAddons-}" ]; then
  preFixupHooks+=('fixupFirefoxAddons')
fi
