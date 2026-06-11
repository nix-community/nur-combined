# nur-packges

**My personal [NUR](https://github.com/nix-community/NUR) repository** which has ONE (1) package (`tetrio-plus` for TETR.IO V10)

**Yes I'm keeping that typo**

## jux how do i use the tetrio plus

Uhh go to the place where the TETR.IO package is and do `(tetrio-desktop.override = { tetrio-plus = nur.repos.juxgd.tetrio-plus; withTetrioPlus = true; })` instead of just `tetrio-desktop`.

BTW I git cloned the thing and included it here because yarn was doing some weird stuff and doing that somehow fixed it. No changes were made to TETR.IO PLUS other than deleting the git files so i could include it in the repo

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/JuxGD/nur-packges/workflows/Build%20and%20populate%20cache/badge.svg)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
-->
[![Cachix Cache](https://img.shields.io/badge/cachix-JuxGD-blue.svg)](https://JuxGD.cachix.org)
