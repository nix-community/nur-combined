# seowebchecker/seoaudit-sdk (Docker Hub)

[![Docker Image Version](https://img.shields.io/docker/v/seowebchecker/seoaudit-sdk?sort=semver)](https://hub.docker.com/r/seowebchecker/seoaudit-sdk)
[![Docker Pulls](https://img.shields.io/docker/pulls/seowebchecker/seoaudit-sdk.svg)](https://hub.docker.com/r/seowebchecker/seoaudit-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

Official Docker image for **seowebchecker-seoaudit-sdk** by [SEOWebChecker.com](https://seowebchecker.com/) — packaged with an interactive web UI and CLI tool.

## Run Web Dashboard

```bash
docker run -d -p 5000:5000 --name seowebchecker seowebchecker/seoaudit-sdk
```

Open `http://localhost:5000` in your browser.

## Run CLI Audit in Docker

```bash
docker run --rm seowebchecker/seoaudit-sdk python -m seowebchecker_seoaudit.cli https://example.com --format json
```

## CI/CD Quality Gate in Docker

```bash
docker run --rm seowebchecker/seoaudit-sdk python -m seowebchecker_seoaudit.cli https://example.com --min-score 85
```

## License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
