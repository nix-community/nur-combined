{
  fetchFromGitHub,
  writeText,
  offlineimap,
}:
let
  no-install-requires-patch = writeText "urlib3.patch" ''
    diff --git a/setup.py b/setup.py
    index d6bc115..356a7f2 100644
    --- a/setup.py
    +++ b/setup.py
    @@ -62,6 +62,4 @@ setup(name="offlineimap",
           scripts=['bin/offlineimap'],
           license=offlineimap.__copyright__ + ", Licensed under the GPL version 2",
           cmdclass={'test': TestCommand},
    -      install_requires=['distro', 'imaplib2>=3.5', 'rfc6555', 'gssapi[kerberos]', 'portalocker[cygwin]', 'urllib3~=1.25.9'],
    -      extras_require={'keyring': ['keyring']},
           )
  '';
in
offlineimap.overrideAttrs (
  _finalAttrs: _previousAttrs: {
    version = "8.0.0.72";
    name = "offlineimap-8.0.0.72";

    src = fetchFromGitHub {
      owner = "OfflineIMAP";
      repo = "offlineimap3";
      rev = "47f74c4408b435e7e8dc2a67e73b3f631af4dbf0";
      hash = "sha256-2aZbZMk8mYRE+iQNZn2JTJwy7FHIiUytNxzSzmPXlmE=";
    };

    patches = [ no-install-requires-patch ];
  }
)
