#!/bin/sh

CI_URL=https://github.com/arcnmx/ci/archive/allnix.tar.gz
CI_URL=/home/arc/projects/arc.github/ci
exec nix run -L --show-trace -f $CI_URL \
	--arg config ./ci/config.nix stage.stable.test -c ci-build "$@"
