# Picks the best wheel of each package in a parsed uv.lock for a Python
# interpreter and platform, from the tags in the wheels' filenames
# (https://packaging.python.org/en/latest/specifications/platform-compatibility-tags/).
#
# Returns a list of `{ name, version, filename, url, sha256 }`, more than one
# per name if the lock has forked resolutions. Packages without a compatible
# wheel (sdists only, or wheels for other platforms) are left out, uv fails
# naming them if they're needed.
{ lib }:

{
  # the parsed uv.lock
  lock,
  python,
  platform,
  # glibc's version, for manylinux wheels
  libcVersion ? null,
}:

let
  # sourceVersion is PyPy's own version for PyPy
  versionParts = lib.splitString "." python.pythonVersion;
  major = builtins.elemAt versionParts 0;
  minor = builtins.elemAt versionParts 1;
  minorInt = lib.toInt minor;

  # cp314, cp314t (free-threaded) or pypy311_pp73
  abiTag = lib.findFirst (tag: tag != "abi3" && tag != "none") null python.pythonABITags;
  isCPython = python.implementation == "cpython";
  # free-threaded builds can't load extensions for the stable ABI
  hasAbi3 = isCPython && builtins.elem "abi3" python.pythonABITags && !lib.hasSuffix "t" abiTag;
  # the interpreter tag of extensions for this version, pp311 for PyPy 3.11
  interpreterTag =
    if isCPython then
      "cp${major}${minor}"
    else if python.implementation == "pypy" then
      "pp${major}${minor}"
    else
      null;

  # the minor version in tags like cp312 or py312, or -1 for py3
  tagMinor =
    prefix: tag:
    if tag == "${prefix}${major}" then
      -1
    else
      let
        match = builtins.match "${prefix}${major}([0-9]+)" tag;
      in
      if match == null then null else lib.toInt (builtins.head match);

  # higher scores are preferred, null if the interpreter can't load the wheel
  interpreterScore =
    pythonTag: abi:
    let
      cpMinor = tagMinor "cp" pythonTag;
      pyMinor = tagMinor "py" pythonTag;
    in
    if abi == abiTag && pythonTag == interpreterTag then
      [
        4
        0
      ]
    else if abi == "abi3" && hasAbi3 && cpMinor != null && cpMinor >= 2 && cpMinor <= minorInt then
      [
        3
        cpMinor
      ]
    else if abi == "none" && pythonTag == interpreterTag then
      [
        2
        0
      ]
    else if abi == "none" && pyMinor != null && pyMinor <= minorInt then
      [
        1
        pyMinor
      ]
    else
      null;

  linuxArch =
    {
      powerpc64le = "ppc64le";
    }
    .${platform.parsed.cpu.name} or platform.parsed.cpu.name;

  # manylinux1, manylinux2010 and manylinux2014 are aliases of glibc versions
  legacyManylinux = {
    manylinux1 = "2.5";
    manylinux2010 = "2.12";
    manylinux2014 = "2.17";
  };

  darwinArchs =
    {
      aarch64 = [
        "arm64"
        "universal2"
      ];
      x86_64 = [
        "x86_64"
        "universal2"
        "intel"
        "universal"
      ];
    }
    .${platform.parsed.cpu.name} or [ ];

  versionScore = version: map lib.toInt (lib.splitString "." version);

  # higher scores are preferred, null if the platform can't load the wheel
  platformScore =
    tag:
    let
      manylinux = builtins.match "manylinux_([0-9]+)_([0-9]+)_(.+)" tag;
      legacy = builtins.match "(manylinux[0-9]+)_(.+)" tag;
      macos = builtins.match "macosx_([0-9]+)_([0-9]+)_(.+)" tag;

      glibc =
        if manylinux != null then
          {
            version = "${builtins.elemAt manylinux 0}.${builtins.elemAt manylinux 1}";
            arch = builtins.elemAt manylinux 2;
          }
        else if legacy != null && legacyManylinux ? ${builtins.head legacy} then
          {
            version = legacyManylinux.${builtins.head legacy};
            arch = builtins.elemAt legacy 1;
          }
        else
          null;
    in
    if tag == "any" then
      [
        1
        0
        0
        0
      ]
    else if
      glibc != null
      && platform.isLinux
      && platform.libc == "glibc"
      && glibc.arch == linuxArch
      && libcVersion != null
      && lib.versionAtLeast libcVersion glibc.version
    then
      [
        2
        0
      ]
      ++ versionScore glibc.version
    else if
      macos != null && platform.isDarwin && builtins.elem (builtins.elemAt macos 2) darwinArchs
    then
      let
        version = "${builtins.elemAt macos 0}.${builtins.elemAt macos 1}";
      in
      if lib.versionAtLeast platform.darwinMinVersion version then
        [
          2
          # wheels for the architecture over universal ones
          (if builtins.elemAt macos 2 == builtins.head darwinArchs then 1 else 0)
        ]
        ++ versionScore version
      else
        null
    else
      null;

  # `{name}-{version}(-{build})?-{python}-{abi}-{platform}.whl`, where each tag
  # can be a set separated by dots
  wheelScore =
    filename:
    let
      parts = lib.splitString "-" (lib.removeSuffix ".whl" filename);
      count = builtins.length parts;
      tagSet = index: lib.splitString "." (builtins.elemAt parts (count - 3 + index));

      interpreterScores = lib.concatMap (
        pythonTag: map (abi: interpreterScore pythonTag abi) (tagSet 1)
      ) (tagSet 0);
      platformScores = map platformScore (tagSet 2);

      best = scores: lib.foldl' maxScore null (lib.filter (score: score != null) scores);
      interpreter = best interpreterScores;
      platform' = best platformScores;
    in
    if count < 5 || interpreter == null || platform' == null then null else interpreter ++ platform';

  maxScore =
    a: b:
    if a == null then
      b
    else if b == null then
      a
    else if lib.compareLists lib.compare a b >= 0 then
      a
    else
      b;

  # %2B is the only escape PyPI uses in filenames, for local versions
  filenameOf =
    url: builtins.replaceStrings [ "%2B" "%2b" ] [ "+" "+" ] (lib.last (lib.splitString "/" url));

  candidates =
    package:
    lib.concatMap (
      wheel:
      let
        filename = filenameOf wheel.url;
        score = wheelScore filename;
      in
      lib.optional (wheel ? url && wheel ? hash && lib.hasPrefix "sha256:" wheel.hash && score != null) {
        inherit filename score;
        inherit (wheel) url;
        sha256 = lib.removePrefix "sha256:" wheel.hash;
      }
    ) (package.wheels or [ ]);

  pick =
    package:
    lib.foldl' (
      best: candidate:
      if best == null || lib.compareLists lib.compare candidate.score best.score > 0 then
        candidate
      else
        best
    ) null (candidates package);
in
lib.concatMap (
  package:
  let
    wheel = pick package;
  in
  lib.optional (wheel != null) {
    inherit (package) name version;
    inherit (wheel) filename url sha256;
  }
) (lock.package or [ ])
