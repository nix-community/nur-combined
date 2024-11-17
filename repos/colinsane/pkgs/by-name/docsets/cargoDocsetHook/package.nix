# add this package to the `nativeBuildInputs` of a rust package to enable $out/share/docsets
# for use in e.g. Zeal.
#
# i build docs inline like this because `cargo docset` (via `cargo doc`) practically does a full compile anyway,
# so may as well stray true to the upstream packaging and simply augment the existing package with a docset build.
#
# cargo-docset docs: <https://github.com/Robzz/cargo-docset>
{
  makeSetupHook,
  cargo,
  cargo-docset,
}:
makeSetupHook {
  name = "cargo-docset-hook";
  propagatedBuildInputs = [
    cargo cargo-docset
  ];
} ./hook.sh
