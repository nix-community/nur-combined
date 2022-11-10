#!/bin/bash
set -o errexit
exec rspamc -h /run/rspamd/worker-controller.sock learn_spam