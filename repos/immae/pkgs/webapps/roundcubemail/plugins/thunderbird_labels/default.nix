{ buildPlugin }:
buildPlugin rec {
  appName = "thunderbird_labels";
  version = "v1.3.2";
  url = "https://github.com/mike-kfed/roundcube-${appName}/archive/${version}.tar.gz";
  sha256 = "1q4x30w66m02v3lw2n8020g0158rmyfzs6gydfk89pa1hs28k9bg";
}
