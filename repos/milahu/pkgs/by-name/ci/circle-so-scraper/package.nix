{
  lib,
  python3,
  fetchFromGitHub,
  setuptools,
  beautifulsoup4,
  playwright,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "circle-so-scraper";
  version = "0-unstable-2026-08-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "circle-so-scraper";
    # https://github.com/maarteek/circle-scraper/pull/1
    rev = "916ae77227762c8553e7cdc647fe804c44d08a86";
    hash = "sha256-LkDVlvvqHgVVxuJrU7t+LM+4MKHrMCbTYkJy5bauE9k=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    beautifulsoup4
    playwright
  ];

  pythonImportsCheck = [
    # "circle_scraper"
  ];

  meta = {
    description = "Circle.so Community Scraper";
    homepage = "https://github.com/milahu/circle-so-scraper";
    changelog = "https://github.com/milahu/circle-so-scraper/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "circle-so-scraper";
  };
})
