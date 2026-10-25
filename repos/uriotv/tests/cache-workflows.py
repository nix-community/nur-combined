#!/usr/bin/env python3
"""Offline regression tests for the Cachix-only CI publication workflows."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class CacheWorkflowTests(unittest.TestCase):
    def test_package_workflow_publishes_only_to_cachix(self):
        body = (ROOT / ".github/workflows/build.yml").read_text()

        self.assertNotIn("attic", body.lower())
        self.assertNotIn("ATTIC_TOKEN", body)
        self.assertNotIn("CI_PUBLISH_LIST_FILE", body)
        self.assertIn('CACHIX_AUTH_TOKEN: ${{ secrets.CACHIX_AUTH_TOKEN }}', body)
        self.assertIn("run: bash scripts/build-ci.sh", body)
        self.assertIn(
            'run: bash scripts/publication-status.sh cache/packages "$CACHIX_OUTCOME"', body
        )

    def test_kernel_workflow_keeps_verified_cachix_publication_only(self):
        body = (ROOT / ".github/workflows/kernel.yml").read_text()
        tools = body.split("      - name: Provide tools from the locked nixpkgs", 1)[1].split(
            "      - name:", 1
        )[0]
        cachix = body.split("      - name: Publish to uriotv and verify StorePath", 1)[1].split(
            "      - name:", 1
        )[0]

        self.assertNotIn("attic", body.lower())
        self.assertNotIn("ATTIC_TOKEN", body)
        self.assertNotIn("nixpkgs#attic-client", tools)
        self.assertIn("nixpkgs#cachix", tools)
        self.assertIn("CACHIX_AUTH_TOKEN: ${{ secrets.CACHIX_AUTH_TOKEN }}", cachix)
        self.assertIn('cachix push uriotv < "$RUNNER_TEMP/publish-paths"', cachix)
        self.assertIn('done < "$RUNNER_TEMP/publish-paths"', cachix)
        self.assertIn("steps.closure.outcome == 'success'", cachix)
        self.assertIn(
            'run: bash scripts/publication-status.sh "cache/kernel/${KERNEL_ATTR}" '
            '"$CLOSURE_OUTCOME" "$CACHIX_OUTCOME"',
            body,
        )
        self.assertIn("--max-jobs 0", body)
        self.assertIn("uriotv.cachix.org-1:", body)
        self.assertIn("nix path-info --sigs", body)

    def test_cache_branch_gate_tracks_verified_publications_only(self):
        body = (ROOT / ".github/workflows/cache-branch.yml").read_text()
        self.assertNotIn("attic", body.lower())
        self.assertIn("publication statuses", body)
        self.assertIn("scripts/promote-cache-branch.sh", body)

    def test_build_script_has_no_private_mirror_export(self):
        body = (ROOT / "scripts/build-ci.sh").read_text()
        self.assertNotIn("CI_PUBLISH_LIST_FILE", body)
        self.assertNotIn("attic", body.lower())
        self.assertIn("cachix push uriotv", body)


if __name__ == "__main__":
    unittest.main(verbosity=2)
