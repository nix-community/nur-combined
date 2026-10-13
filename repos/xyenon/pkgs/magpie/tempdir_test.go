package fixture

import (
	"testing"

	"github.com/yetone/magpie/internal/plugin"
)

// nixTempDir prevents background plugin writes from racing directory cleanup,
// which can otherwise fail removal or recreate files after their test ends.
func nixTempDir(t testing.TB) string {
	t.Helper()
	dir := t.TempDir()
	// Cleanups run in reverse order, so plugin work settles before TempDir removes dir.
	t.Cleanup(plugin.Settle)
	return dir
}
