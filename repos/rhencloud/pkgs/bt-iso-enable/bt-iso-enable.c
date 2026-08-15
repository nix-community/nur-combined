#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kprobes.h>
#include <linux/init.h>
#include <linux/workqueue.h>
#include <linux/jiffies.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("RhenCloud");
MODULE_DESCRIPTION("Enable Bluetooth ISO socket by calling iso_init via kprobe");
MODULE_SOFTDEP("pre: bluetooth");

static int do_iso_init(void)
{
    struct kprobe kp = { .symbol_name = "iso_init" };
    int (*iso_init_fn)(void);
    int ret;

    ret = register_kprobe(&kp);
    if (ret < 0)
        return ret;

    iso_init_fn = (int (*)(void))kp.addr;
    unregister_kprobe(&kp);

    return iso_init_fn();
}

static void retry_work_fn(struct work_struct *work);
static DECLARE_DELAYED_WORK(retry_work, retry_work_fn);

static void retry_work_fn(struct work_struct *work)
{
    int ret = do_iso_init();
    if (ret == 0 || ret == -EALREADY)
        pr_info("bt-iso-enable: iso_init succeeded on retry\n");
    else
        pr_info("bt-iso-enable: retrying iso_init failed (err=%d)\n", ret);
}

static int __init bt_iso_enable_init(void)
{
    int ret = do_iso_init();
    if (ret == 0 || ret == -EALREADY) {
        pr_info("bt-iso-enable: iso_init succeeded\n");
        return 0;
    }

    pr_info("bt-iso-enable: deferred (err=%d), scheduling retry in 10s\n", ret);
    schedule_delayed_work(&retry_work, msecs_to_jiffies(10000));
    return 0;
}

static void __exit bt_iso_enable_exit(void)
{
    cancel_delayed_work_sync(&retry_work);
}

module_init(bt_iso_enable_init);
module_exit(bt_iso_enable_exit);
