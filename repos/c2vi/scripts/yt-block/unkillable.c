#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/proc_fs.h>
#include <linux/sched.h>
#include <linux/sched/signal.h>
#include <linux/pid.h>

/* device access functions */
ssize_t unkillable_write(struct file *filp, const char *buf, size_t count, loff_t *f_pos);
ssize_t unkillable_read(struct file *filp, char *buf, size_t count, loff_t *f_pos);
int unkillable_open(struct inode *inode, struct file *filp);
int unkillable_release(struct inode *inode, struct file *filp);

void unkillable_exit(void);
int unkillable_init(void);

struct file_operations unkillable_fops = {
  .read = unkillable_read,
  .write = unkillable_write,
  .open = unkillable_open,
  .release = unkillable_release
};

int unkillable_major = 117;

void make_unkillable(int pid) {

  struct pid *pid_struct;
  struct task_struct *p;

  pr_info("ok ... pid in fn: %d \n", pid);

  /* get the pid struct */
  pid_struct = find_get_pid((int) pid);

  /* get the task_struct from the pid */
  p = pid_task(pid_struct, PIDTYPE_PID);

  /* add the flag */
  p->signal->flags = p->signal->flags | SIGNAL_UNKILLABLE;
  printk("Unkillable: pid %d marked as unkillable\n", (int) pid);
}


int unkillable_init(void) 
{
  if (register_chrdev(unkillable_major, "unkillable", &unkillable_fops) < 0 ) {
    printk("Unkillable: cannot obtain major number %d\n", unkillable_major);
    return 1;
  }

  printk("Inserting unkillable module\n"); 
  return 0;
}

void unkillable_exit(void) 
{
  unregister_chrdev(unkillable_major, "unkillable");
  printk("Removing unkillable module\n");
}

int unkillable_open(struct inode *inode, struct file *filp) 
{
  return 0;
}

int unkillable_release(struct inode *inode, struct file *filp) 
{
  return 0;
}

ssize_t unkillable_read(struct file *filp, char *buf, size_t count, loff_t *f_pos) 
{ 
  
  /* interpret count to read as target pid */
  printk("Unkillable: Got pid %d", (int) count);

  make_unkillable(count);

  
  if (*f_pos == 0) { 
    *f_pos+=1; 
    return 1; 
  } else { 
    return 0; 
  }
}

ssize_t unkillable_write(struct file *filp, const char *buf, size_t count, loff_t *f_pos) 
{
  int ret;
  unsigned long long res;

  ret = kstrtoull_from_user(buf, count, 10, &res);

  if (ret) {
      /* Negative error code. */
      pr_info("ko = %d\n", ret);
      return ret;
  } else {
      pr_info("ok ... pid: %llu\n", res);
      make_unkillable( (int) res);
      return count;
  }
}


/* Declaration of the init and exit functions */
module_init(unkillable_init);
module_exit(unkillable_exit);

MODULE_LICENSE("GPL");

