#!/usr/bin/env bash
set -e
set -o pipefail

for repository in $(gcloud container images list --format='get(name)');
do
    echo ">> Cleaning ${repository}…"
    while true; do
	DIGEST=$(gcloud container images list-tags ${repository} --filter='-tags:*' --format='get(digest)' --limit=1)
	if [ -z "${DIGEST}" ]; then
	    break
	fi
	gcloud container images delete ${repository}@${DIGEST} --force-delete-tags --quiet || break
    done
done
