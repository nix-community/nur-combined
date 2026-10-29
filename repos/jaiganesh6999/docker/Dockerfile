# SEOWebChecker SEO Audit SDK Container
# Official Website: https://seowebchecker.com/

FROM python:3.11-alpine

LABEL org.opencontainers.image.title="seowebchecker-seoaudit-sdk" \
      org.opencontainers.image.description="Lightweight website SEO audit tool and CLI by SEOWebChecker" \
      org.opencontainers.image.url="https://seowebchecker.com/" \
      org.opencontainers.image.source="https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk" \
      org.opencontainers.image.licenses="MIT"

WORKDIR /app

# Copy SDK python directory & demo server
COPY python/ /app/python/
COPY demo_server.py /app/demo_server.py

# Install dependencies
RUN pip install --no-cache-dir requests beautifulsoup4

ENV PYTHONPATH="/app/python"
EXPOSE 5000

# Default: starts the interactive web dashboard on port 5000
# Alternatively override entrypoint for CLI: `docker run seowebchecker/seoaudit-sdk python -m seowebchecker_seoaudit.cli https://example.com`
CMD ["python", "demo_server.py"]
