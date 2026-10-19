#!/usr/bin/env bash
set -euo pipefail

qcow="${1:?Usage: $0 /path/to/image.qcow2}"

bucket="_TEMP_NIXOS_IMAGES_$RANDOM"

echo "Using QCOW: $qcow"
echo "Creating temporary bucket: $bucket"

root_ocid="$(
	oci iam compartment list \
		--all \
		--compartment-id-in-subtree true \
		--access-level ACCESSIBLE \
		--include-root \
		--raw-output \
		--query "data[?contains(id,'tenancy')].id | [0]"
)"

oci os bucket create \
	-c "$root_ocid" \
	--name "$bucket" \
	--raw-output \
	--query "data.id" >/dev/null

# Cleanup on exit
trap 'echo "Removing temporary bucket"; oci os bucket delete --force --name "$bucket"' INT TERM EXIT

echo "Uploading image to temporary bucket"
oci os object put -bn "$bucket" --file "$qcow" --name nixos.qcow2

echo "Importing image as a Custom Image"

bucket_ns="$(
	oci os ns get --query "data" --raw-output
)"

image_id="$(
	oci compute image import from-object \
		-c "$root_ocid" \
		--namespace "$bucket_ns" \
		--bucket-name "$bucket" \
		--name nixos.qcow2 \
		--operating-system NixOS \
		--source-image-type QCOW2 \
		--launch-mode PARAVIRTUALIZED \
		--display-name NixOS \
		--raw-output \
		--query "data.id"
)"

cat <<EOF

Image created!

Manage it here:
https://cloud.oracle.com/compute/images/$image_id

EOF

echo "Waiting 15 minutes before cleanup (OCI import workaround)..."
sleep $((15 * 60))

echo "Cleaning up pre-auth requests (if any)"
par_id="$(
	oci os preauth-request list \
		--bucket-name "$bucket" \
		--raw-output \
		--query "data[0].id"
)"

if [[ -n "${par_id:-}" ]]; then
	oci os preauth-request delete \
		--bucket-name "$bucket" \
		--par-id "$par_id"
fi

echo "Deleting uploaded QCOW image object"
oci os object delete -bn "$bucket" --object-name nixos.qcow2 --force
