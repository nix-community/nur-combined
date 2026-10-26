package fixture

import (
	"testing"
	"time"
)

// NixFreezeBackupClock fixes backup names without isolating shared notification
// channels from the plugin callbacks that invalidate them.
func NixFreezeBackupClock(t testing.TB) time.Time {
	t.Helper()
	at, previous := time.Now(), now
	now = func() time.Time { return at }
	t.Cleanup(func() { now = previous })
	return at
}
