package main

import "testing"

func TestWorkloadCgroupIdentity(t *testing.T) {
	for _, tc := range []struct {
		path, unit, want string
	}{
		{"/system.slice/matrix-synapse.service", "matrix-synapse.service", "/system.slice/matrix-synapse.service"},
		{"/apps.slice/apps-media.slice/matrix-synapse.service/.control", "matrix-synapse.service", "/apps.slice/apps-media.slice/matrix-synapse.service"},
		{"/matrix-synapse.service/worker", "matrix-synapse.service", "/matrix-synapse.service"},
		// A sibling with the same UID cannot select the other workload's gate.
		{"/system.slice/matrix-synapse-s3-upload.service", "matrix-synapse.service", ""},
		{"/system.slice/matrix-synapse.service-copy", "matrix-synapse.service", ""},
		{"/user.slice/user-1000.slice/user@1000.service/app.slice/matrix-synapse.service", "matrix-synapse.service", ""},
		{"/system.slice/other.service/delegated.slice/matrix-synapse.service", "matrix-synapse.service", ""},
		{"/system.slice/matrix-synapse.service/../other.service", "matrix-synapse.service", ""},
		{"/", "", ""}, {"relative", "", ""},
		{"/user.slice/user-984.slice/libpod-test.scope/container", "", "/user.slice/user-984.slice/libpod-test.scope/container"},
	} {
		got, err := workloadCgroup(tc.path, tc.unit)
		if got != tc.want || (err != nil) != (tc.want == "") {
			t.Errorf("workloadCgroup(%q, %q) = %q, %v; want %q", tc.path, tc.unit, got, err, tc.want)
		}
	}
}
