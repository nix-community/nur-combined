{ fetchFromGitHub
, rope
}:

rope.overridePythonAttrs (oldAttrs: rec {
  version = "1.10.0";
  src = fetchFromGitHub {
    inherit (oldAttrs.src) owner repo;
    rev = version;
    hash = "sha256-ji3BnY5zFA7r+EhBs+4HOuwZkWOhWPTosdeF2+V69Mc=";
  };
  patches = (oldAttrs.patches or [ ]) ++ [
    ./rope.patch
  ];
})
