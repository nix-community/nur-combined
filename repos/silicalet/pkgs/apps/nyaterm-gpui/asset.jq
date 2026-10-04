.[]
| select(.tag_name == ("v" + $version))
| .assets[]
| select(.name == $asset)
