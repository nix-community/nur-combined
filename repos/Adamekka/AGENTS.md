# Repository instructions

## Automated updates

- In this repository, automated dependency and version updates must commit directly to `main`, not open pull requests.
- Validate the exact update with the required build and test checks before pushing. Never push untested updates or force-push `main`.
- If `main` changes during validation, abort the push and validate again against the new base before retrying.
