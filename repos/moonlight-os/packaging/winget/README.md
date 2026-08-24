# Winget packaging

`render.sh` creates the three versioned manifests for `MoonlightOS.Helios`.
The release workflow renders them from the exact NSIS installer it publishes,
validates them with Windows Package Manager, and submits one community-repo PR.

The `WINGET_TOKEN` repository secret must contain a GitHub token accepted by
WingetCreate. It is only exposed to the tag-only submission job.
