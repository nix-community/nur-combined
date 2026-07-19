# Add missing npm "resolved" URLs so fetchNpmDeps can download packages
# whose lock entries only have integrity + version (SponsorBlock release zip).

def registry_tarball($name; $version):
  if ($name | startswith("@")) then
    ($name | split("/")[1]) as $pkg
    | "https://registry.npmjs.org/\($name)/-/\($pkg)-\($version).tgz"
  else
    "https://registry.npmjs.org/\($name)/-/\($name)-\($version).tgz"
  end;

def should_patch:
  (.resolved | not)
  and (.integrity != null)
  and ((.version | type) == "string")
  and (.version != "")
  and ((.version | contains("://")) | not)
  and ((.version | test("^(file:|git\\+|github:|workspace:)")) | not);

.packages |= with_entries(
  if (.key | startswith("node_modules/"))
     and (.value | type == "object")
     and (.value | should_patch)
  then
    .value.resolved = registry_tarball(
      (.key | split("node_modules/")[-1]);
      .value.version
    )
  else
    .
  end
)
| .dependencies |= with_entries(
  if (.value | type == "object") and (.value | should_patch) then
    .value.resolved = registry_tarball(.key; .value.version)
  else
    .
  end
)
