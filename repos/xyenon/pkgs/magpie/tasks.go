package fixture

import (
	"sync"
	"testing"
)

var nixTasks = struct {
	sync.Mutex
	pending int
	changed *sync.Cond
}{}

// Register before starting the goroutine so cleanup sees work not yet scheduled.
func nixBeginTask() func() {
	nixTasks.Lock()
	if nixTasks.changed == nil {
		nixTasks.changed = sync.NewCond(&nixTasks.Mutex)
	}
	nixTasks.pending++
	nixTasks.Unlock()
	return func() {
		nixTasks.Lock()
		nixTasks.pending--
		nixTasks.changed.Broadcast()
		nixTasks.Unlock()
	}
}

func nixTaskTempDir(t testing.TB, settle ...func()) string {
	t.Helper()
	dir := t.TempDir()
	t.Cleanup(func() {
		for _, wait := range settle {
			wait()
		}
		nixWaitTasks()
	})
	return dir
}

func nixWaitTasks() {
	nixTasks.Lock()
	defer nixTasks.Unlock()
	for nixTasks.pending != 0 {
		nixTasks.changed.Wait()
	}
}
