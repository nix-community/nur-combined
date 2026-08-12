/* SPDX-License-Identifier: LGPL-2.1-or-later */

/*
 * A minimal, hand-written stand-in for the vmlinux.h that systemd normally
 * obtains by dumping the *build machine's* kernel BTF:
 *
 *     bpftool btf dump file /sys/kernel/btf/vmlinux format c
 *
 * That is not an option for Nixpkgs: the build sandbox has no /sys, the result
 * would depend on whichever kernel the builder happens to run (breaking
 * reproducibility and cross compilation), and the resulting systemd has to run
 * on any kernel a user picks anyway. So instead of the ~135k lines describing
 * every type in the kernel, this file declares only the handful of kernel types
 * that systemd's BPF programs actually touch. It is passed to the build via
 * meson's `vmlinux-h-path` option, which enables `HAVE_VMLINUX_H` and with it
 * userns-restrict (nsresourced/mountfsd), restrict-fsaccess and the networkd
 * sysctl monitor.
 *
 * The approach follows the one proposed upstream in
 * https://github.com/systemd/systemd/pull/40482, which replaces vmlinux.h with
 * inline struct definitions in the BPF sources. That PR has not been merged, so
 * we keep the equivalent definitions on our side instead of patching systemd.
 *
 * Everything here is CO-RE relocatable: every struct carries
 * __attribute__((preserve_access_index)), so clang emits BTF relocations for
 * member accesses and libbpf rewrites the offsets against the BTF of the kernel
 * that is actually running. Consequently only the member *names* and their
 * *types* have to match the kernel — neither the order of the members nor the
 * completeness of the struct matters, and a struct may be left empty if the BPF
 * code only ever takes its address. This is also why the definitions are
 * architecture independent.
 *
 * offsetof() and container_of() are relocated as well: libbpf's
 * <bpf/bpf_helpers.h> deliberately redefines them in terms of
 * `&((type *)0)->member` rather than __builtin_offsetof() precisely so that
 * they go through the same machinery. That is what makes real_mount() in
 * src/bpf/userns-restrict.bpf.c work despite struct mount being declared with
 * only three of its members here.
 *
 * Deliberately *not* defined here: __VMLINUX_H__. libbpf's <bpf/bpf_tracing.h>
 * takes that as a signal that struct pt_regs has the kernel-internal member
 * names (`di`, `si`, ... on x86-64) rather than the userspace ones (`rdi`,
 * `rsi`, ...). We pull in the UAPI <asm/ptrace.h> below, which provides the
 * userspace layout, so bpf_tracing.h must stay on its non-vmlinux path.
 *
 * When adding a new BPF program to the systemd package, check which kernel types
 * it dereferences and add the corresponding members below. `pahole`, or a
 * vmlinux.h generated from a real kernel, are the reference for member names and
 * types.
 */

#pragma once

/* struct pt_regs / struct user_pt_regs, needed by BPF_KPROBE(). */
#include <asm/ptrace.h>
/* The BPF UAPI: enum bpf_map_type, enum bpf_cmd, union bpf_attr,
 * struct bpf_sysctl, BPF_ANY, ... A real vmlinux.h carries these too, since
 * they are compiled into the kernel; <bpf/bpf_helpers.h> requires them and must
 * be included after this file. */
#include <linux/bpf.h>
#include <linux/types.h>
/* bool, size_t, {u,}int*_t, pid_t, uid_t, gid_t. The kernel spells these the
 * same way, so BPF code written against a generated vmlinux.h keeps working. */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

/* Kernel-style fixed width aliases, as used by src/bpf/sysctl-monitor.bpf.c. */
typedef __u32 u32;
typedef __u64 u64;

/* include/linux/types.h */
typedef unsigned short umode_t;

/* include/linux/uidgid_types.h. uid_t/gid_t are 32 bit in both the kernel
 * (__kernel_uid32_t) and libc, so the layout matches. */
typedef struct {
        uid_t val;
} kuid_t;

typedef struct {
        gid_t val;
} kgid_t;

/* include/linux/security.h, added in kernel v6.5 by 2deeb6c333e5 together with
 * the bdev_setintegrity LSM hook. systemd probes for this enum to decide whether
 * to build src/bpf/restrict-fsaccess.bpf.c. */
enum lsm_integrity_type {
        LSM_INT_DMVERITY_SIG_VALID,
        LSM_INT_DMVERITY_ROOTHASH,
        LSM_INT_FSVERITY_BUILTINSIG_VALID,
};

struct cred;
struct dentry;
struct inode;
struct mnt_namespace;
struct user_namespace;
struct vfsmount;

/* include/linux/blk_types.h. bd_dev is a dev_t, i.e. a u32 — do not spell it
 * dev_t here, libc's dev_t is 64 bit and the load would be too wide. */
struct block_device {
        u32 bd_dev;
} __attribute__((preserve_access_index));

/* include/linux/fs.h */
struct super_block {
        u32 s_dev; /* dev_t, see above */
} __attribute__((preserve_access_index));

struct inode {
        struct super_block *i_sb;
} __attribute__((preserve_access_index));

struct file {
        struct inode *f_inode;
} __attribute__((preserve_access_index));

struct dentry {
        struct inode *d_inode;
} __attribute__((preserve_access_index));

struct path {
        struct vfsmount *mnt;
        struct dentry *dentry;
} __attribute__((preserve_access_index));

/* include/linux/binfmts.h */
struct linux_binprm {
        struct file *file;
} __attribute__((preserve_access_index));

/* include/linux/mm_types.h. On recent kernels vm_flags lives inside an
 * anonymous union; CO-RE looks through those, so a plain member works. Its type
 * is vm_flags_t, i.e. unsigned long. */
struct vm_area_struct {
        unsigned long vm_flags;
        struct file *vm_file;
} __attribute__((preserve_access_index));

/* include/linux/cred.h */
struct cred {
        kuid_t fsuid;
        kgid_t fsgid;
        struct user_namespace *user_ns;
} __attribute__((preserve_access_index));

/* include/linux/sched.h */
struct task_struct {
        pid_t tgid;
        const struct cred *cred;
} __attribute__((preserve_access_index));

/* include/linux/ns_common.h */
struct ns_common {
        unsigned int inum;
} __attribute__((preserve_access_index));

/* include/linux/user_namespace.h */
struct user_namespace {
        struct user_namespace *parent;
        struct ns_common ns;
} __attribute__((preserve_access_index));

/* fs/mount.h */
struct mnt_namespace {
        struct user_namespace *user_ns;
} __attribute__((preserve_access_index));

/* include/linux/mount.h. Left empty on purpose: src/bpf/userns-restrict.bpf.c
 * only ever passes struct vfsmount around by pointer and container_of()s it
 * back to the struct mount it is embedded in. */
struct vfsmount {
} __attribute__((preserve_access_index));

/* fs/mount.h — private to the VFS, but present in the kernel's BTF. */
struct mount {
        struct vfsmount mnt;
        struct mnt_namespace *mnt_ns;
        int mnt_id;
} __attribute__((preserve_access_index));

/* include/linux/bpf.h — the kernel-internal parts, not the UAPI included above.
 * Used by src/bpf/restrict-fsaccess.bpf.c to guard its own maps, programs and
 * links against everyone but PID 1. */
struct bpf_map {
        u32 id;
} __attribute__((preserve_access_index));

struct bpf_prog_aux {
        u32 id;
} __attribute__((preserve_access_index));

struct bpf_prog {
        struct bpf_prog_aux *aux;
} __attribute__((preserve_access_index));
