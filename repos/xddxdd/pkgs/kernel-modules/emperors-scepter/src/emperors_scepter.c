#include <linux/module.h>
#include <linux/kthread.h>
#include <linux/sched.h>

static const char * const scepter_signals[] = {
	"NeiKos496",
	"PhiLia093",
	"OreXis945",
	"EpieiKeia216",
	"SkeMma720",
	"HubRis504",
	"ApoRia432",
	"PoleMos600",
	"KaLos618",
	"EleOs252",
	"HapLotes405",
	"SkoPeo365",
};

#define NUM_SIGNALS ARRAY_SIZE(scepter_signals)

static struct task_struct *scepter_tasks[NUM_SIGNALS];

static int scepter_thread(void *data)
{
	while (!kthread_should_stop()) {
		set_current_state(TASK_IDLE);
		schedule();
	}
	set_current_state(TASK_RUNNING);
	return 0;
}

static int __init emperors_scepter_init(void)
{
	int i;

	for (i = 0; i < NUM_SIGNALS; i++) {
		struct task_struct *t;

		t = kthread_run(scepter_thread, NULL, "%s", scepter_signals[i]);
		if (IS_ERR(t)) {
			pr_err("emperors-scepter: failed to spawn %s: %ld\n",
			       scepter_signals[i], PTR_ERR(t));
			while (--i >= 0)
				kthread_stop(scepter_tasks[i]);
			return PTR_ERR(t);
		}
		scepter_tasks[i] = t;
		pr_info("emperors-scepter: %s started (pid %d)\n",
			scepter_signals[i], t->pid);
	}
	return 0;
}

static void __exit emperors_scepter_exit(void)
{
	int i;

	for (i = 0; i < NUM_SIGNALS; i++) {
		kthread_stop(scepter_tasks[i]);
		pr_info("emperors-scepter: %s stopped\n", scepter_signals[i]);
	}
}

module_init(emperors_scepter_init);
module_exit(emperors_scepter_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("lantian");
MODULE_DESCRIPTION("Spawns idle kthreads for the twelve Scepter δ-me13 signals");
