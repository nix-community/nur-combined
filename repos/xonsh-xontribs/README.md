# nur-packages

**A collection of xonsh-xontribs for [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/drmikecrowe/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-<YOUR_CACHIX_CACHE_NAME>-blue.svg)](https://<YOUR_CACHIX_CACHE_NAME>.cachix.org)

The following xontribs are available in this NUR repo:

- [xontrib-chatgpt](https://github.com/jpal91/xontrib-chatgpt)
- [xontrib-clp](https://github.com/anki-code/xontrib-clp)
- [xontrib-direnv](https://github.com/74th/xonsh-direnv)
- [xontrib-dot-dot](https://github.com/yggdr/xontrib-dotdot)
- [xontrib-gitinfo](https://github.com/dyuri/xontrib-gitinfo)
- [xontrib-prompt-starship](https://github.com/anki-code/xontrib-prompt-starship)
- [xontrib-readable-traceback](https://github.com/vaaaaanquish/xontrib-readable-traceback)
- [xontrib-sh](https://github.com/anki-code/xontrib-sh)
- [xontrib-term-integrations](https://github.com/jnoortheen/xontrib-term-integrations)
- [xontrib-zoxide](https://github.com/dyuri/xontrib-zoxide)

## Contributing

This is still very much a work in progress, and will be enhanced over time.  However, the shell for a given xontrib is created by the `create-xontrib-overlay.xsh` script.  This will build a shell with a possible build setup for the xontrib that you can test.  Submit a PR and we will expand this repo with as many xontribs as we can.
