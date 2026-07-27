{ fetchFromGitHub
, python3Packages
, lib
, fetchpatch
}:

python3Packages.buildPythonApplication rec {
	pname = "obsidian-to-hugo";
	version = "master";

  format = "pyproject";

	src = fetchFromGitHub {
		owner = "devidw";
	  repo = "obsidian-to-hugo";
    rev = "60290a8174591a8f1b5b8b46acd47a72546f1972";
    sha256 = "sha256-pfTVoehltiWdfEnzwi6zPihW3yJJmwq5N42MV3G1Qw0=";
	};

  patches = [
    (fetchpatch {
      url = "https://github.com/devidw/obsidian-to-hugo/pull/26.patch";
      sha256 = "sha256-ky4SdvIpbDEU1Wb+Gc95P9VT6BtvpmeEU82EIOm4ZXk=";
    })
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  meta = with lib; {
    description = "Process Obsidian notes to publish them with Hugo.";
    longDescription = ''
      Supports transformation of Obsidian wiki links into Hugo shortcodes for internal linking.
    '';
    homepage = "https://github.com/devidw/obsidian-to-hugo";
    license = licenses.mit;
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
