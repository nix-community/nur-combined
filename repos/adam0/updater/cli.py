from __future__ import annotations

import argparse
import logging
import os

from .discovery import discover_packages, filter_packages
from .manifest import list_release_asset_manifests, update_release_asset_manifest
from .models import UpdateResult
from .package_backend import update_package
from .report import print_report

logger = logging.getLogger(__name__)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Update NUR packages with per-package validation")
    parser.add_argument("--system", default=os.environ.get("SYSTEM", "x86_64-linux"))
    parser.add_argument("--package", action="append", default=[])
    parser.add_argument("--backend", choices=["nix-update", "manifest", "all"], default="all")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--report", choices=["text", "json"], default="text")
    parser.add_argument("--fail-on-invalid", action="store_true")
    parser.add_argument("--timeout", default=os.environ.get("UPDATE_TIMEOUT", "10m"))
    parser.add_argument("--verbose", action="store_true", help="show updater progress logs")
    args = parser.parse_args(argv)

    logging.basicConfig(
        format="%(levelname)s %(name)s: %(message)s",
        level=logging.INFO if args.verbose else logging.WARNING,
    )

    results: list[UpdateResult] = []
    if args.backend in {"nix-update", "all"}:
        refs = filter_packages(discover_packages(args.system), args.package)
        logger.info("updating %d nix package(s)", len(refs))
        for ref in refs:
            results.append(update_package(ref, dry_run=args.dry_run, timeout=args.timeout))

    if args.backend in {"manifest", "all"}:
        manifests = list_release_asset_manifests()
        logger.info("updating %d release asset manifest(s)", len(manifests))
        for manifest in manifests:
            if args.package and not any(name in str(manifest) for name in args.package):
                continue
            results.append(update_release_asset_manifest(manifest, dry_run=args.dry_run))

    print_report(results, args.report)
    if any(result.status == "failed" for result in results):
        return 1
    if args.fail_on_invalid and any(result.status == "invalid" for result in results):
        return 1
    return 0
