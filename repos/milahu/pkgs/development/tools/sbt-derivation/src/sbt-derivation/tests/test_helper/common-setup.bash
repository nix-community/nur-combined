#!/usr/bin/env bash

common_setup() {
	tests_dir="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
	latest_sbt_version="1.7.1"
	latest_scala3_version="3.1.3"
	latest_scala213_version="2.13.8"
	latest_scala212_version="2.12.6"
	load 'test_helper/utils'
}
