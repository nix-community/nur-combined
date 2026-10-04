[.[] | select(.tag_name | test("^v2\\.0\\.0-preview\\.[0-9]+$")) | .tag_name]
| max_by(capture("^v2\\.0\\.0-preview\\.(?<n>[0-9]+)$").n | tonumber)
| sub("^v"; "")
