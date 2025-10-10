# !/usr/bin/env python3
import requests
import sys
import os
import argparse
from github import Github
import github
from concurrent.futures import ThreadPoolExecutor, as_completed


class CheckSyncer:
    def __init__(self, github_token, forgejo_url):
        self.github = Github(auth=github.Auth.Token(github_token))
        self.forgejo_url = forgejo_url.rstrip('/')

    def get_forgejo_checks(self, repo, commit_sha):
        """Retrieve checks from Forgejo"""
        url = (f"{self.forgejo_url}/api/v1/repos/{repo}/"
               f"commits/{commit_sha}/status")

        try:
            response = requests.get(url)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error retrieving checks from Forgejo: {e}")
            return None

    def create_github_status(self, repo_name, commit_sha, state,
                             description, context, target_url):
        """Create status on GitHub using PyGithub"""
        try:
            repo = self.github.get_repo(repo_name)
            commit = repo.get_commit(commit_sha)
            commit.create_status(
                state=state,
                target_url=target_url,
                description=description,
                context=context
            )
            return True
        except Exception as e:
            print(f"Error creating status on GitHub: {e}")
            return False

    def _sync_single_check(self, repo, commit_sha, check, state_mapping):
        """Synchronize a single check"""
        raw_context = check.get('context', 'check')

        # Skip mirror-checks job to avoid self-sync loop
        if 'mirror-checks' in raw_context:
            return None

        # Create cleaner context names
        context = self._create_clean_context(raw_context)

        # Build absolute target URL
        target_url = check.get('target_url', f"/{repo}")
        if target_url.startswith('/'):
            target_url = f"{self.forgejo_url}{target_url}"

        # Map state and create status
        state = state_mapping.get(
            check.get('status', 'pending'), 'pending')
        description = check.get('description', '')[:140]

        if self.create_github_status(
                repo, commit_sha, state, description,
                context, target_url):
            print(f"✅ Synchronized: {context}")
            return True
        else:
            print(f"❌ Error: {context}")
            return False

    def sync_checks(self, repo, commit_sha):
        """Synchronize all checks in parallel"""
        print(f"Synchronizing checks for {repo}@{commit_sha}")

        # Retrieve checks from Forgejo
        forgejo_data = self.get_forgejo_checks(repo, commit_sha)
        if not forgejo_data:
            print("No checks found on Forgejo")
            return False

        # Map Forgejo states -> GitHub
        state_mapping = {
            "success": "success",
            "failure": "failure",
            "pending": "pending",
            "error": "error",
            "warning": "failure"  # GitHub doesn't have "warning"
        }

        success_count = 0

        # Synchronize checks in parallel
        if 'statuses' in forgejo_data:
            with ThreadPoolExecutor(max_workers=5) as executor:
                futures = [
                    executor.submit(
                        self._sync_single_check, repo, commit_sha,
                        check, state_mapping
                    )
                    for check in forgejo_data['statuses']
                ]

                for future in as_completed(futures):
                    result = future.result()
                    if result is True:
                        success_count += 1

        print(f"Synchronized {success_count} checks")
        return success_count > 0

    def _create_clean_context(self, raw_context):
        """Create clean, readable context names for GitHub"""
        # Remove common prefixes and suffixes
        context = raw_context

        # Remove workflow name prefix if present
        if ' / ' in context:
            context = context.split(' / ', 1)[1]

        # Remove common suffixes
        context = context.replace(' (push)', '').replace(' (pull_request)', '')

        # Replace / with - for GitHub compatibility
        context = context.replace('/', '-')

        return context


def main():
    parser = argparse.ArgumentParser(
        description='Synchronize checks from Forgejo to GitHub')
    parser.add_argument('--repo', required=True,
                        help='Repository (format: owner/name)')
    parser.add_argument('--commit', required=True, help='Commit SHA')
    parser.add_argument('--github-token',
                        help='GitHub token (or use GITHUB_TOKEN env)')
    parser.add_argument('--forgejo-url',
                        help='Forgejo URL (or use FORGEJO_URL env)')

    args = parser.parse_args()

    # Get tokens from arguments or environment variables
    github_token = args.github_token or os.getenv('GITHUB_TOKEN')
    forgejo_url = args.forgejo_url or os.getenv('FORGEJO_URL')

    if not all([github_token, forgejo_url]):
        print("Error: Missing tokens or URL. Use --help for details")
        sys.exit(1)

    syncer = CheckSyncer(github_token, forgejo_url)

    if syncer.sync_checks(args.repo, args.commit):
        print("✅ Synchronization completed")
        sys.exit(0)
    else:
        print("❌ Synchronization failed")
        sys.exit(1)


if __name__ == "__main__":
    main()
