{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  setuptools,
  aiofiles,
  aiohttp,
  aiosqlite,
  yt-dlp,
  ffmpeg-full,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "tubefeed";
  version = "2.1.7";
  disabled = pythonOlder "3.10";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "troebs";
    repo = "tubefeed";
    tag = version;
    hash = "sha256-n4A0ltxpBkettQIZ8Y38NXpI934ySmvaF5HTs+AHnZI=";
  };

  patches = [
    ./entry_points.patch
    ./datetime_parse_fix.patch
  ];

  postPatch = ''
    substituteInPlace setup.py --replace-fail "version = '0.1.0'" "version = '${version}'"
  '';

  build-system = [setuptools];

  pythonRelaxDeps = true;

  dependencies = [
    aiofiles
    aiohttp
    aiosqlite
    yt-dlp
  ];

  postInstall = ''
    wrapProgram $out/bin/tubefeed \
      --prefix PATH : ${lib.makeBinPath [yt-dlp ffmpeg-full]}
  '';

  pythonImportsCheck = [
    "tubefeed"
  ];

  meta = with lib; {
    description = "Seamlessly integrate YouTube with Audiobookshelf";
    homepage = "https://gitlab.com/troebs/tubefeed";
    license = licenses.mit;
    maintainers = with maintainers; [renesat];
  };
}
