// SPDX-License-Identifier: MIT
// Socket redirection only. DNS, CONNECT and TLS remain in user space.
#include <linux/bpf.h>
#include <linux/in.h>
#include <linux/in6.h>
#include <linux/socket.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

#define AF_INET 2
#define AF_INET6 10
#define SOCK_STREAM 1
#define SOCK_DGRAM 2
#define DNS_SLOTS 8

const volatile __u16 tcp_port = 15001;
const volatile __u16 dns_base = 15053;

struct destination {
    __u64 cookie;
    __u64 created;
    __u32 family;
    __u32 port;
    __u32 address[4];
};

struct connection_key {
    __u64 netns;
    __u32 family;
    __u32 source_port;
    __u32 proxy_port;
    __u32 pad;
    __u32 source[4];
};

struct tcp_state {
    struct destination original;
    struct connection_key key;
    __u32 tracked;
};

struct udp_state {
    struct destination peers[DNS_SLOTS];
};

struct {
    __uint(type, BPF_MAP_TYPE_SK_STORAGE);
    __uint(map_flags, BPF_F_NO_PREALLOC);
    __type(key, int);
    __type(value, struct tcp_state);
} tcp_storage SEC(".maps");

struct {
    __uint(type, BPF_MAP_TYPE_SK_STORAGE);
    __uint(map_flags, BPF_F_NO_PREALLOC);
    __type(key, int);
    __type(value, struct udp_state);
} udp_storage SEC(".maps");

// Workers inherit only a descriptor for this map. They cannot write it.
struct {
    __uint(type, BPF_MAP_TYPE_LRU_HASH);
    __uint(max_entries, 16384);
    __uint(map_flags, BPF_F_RDONLY);
    __type(key, struct connection_key);
    __type(value, struct destination);
} connections SEC(".maps");

static __always_inline int loopback(struct bpf_sock_addr *ctx, int v6)
{
    if (!v6)
        return (bpf_ntohl(ctx->user_ip4) >> 24) == 127;
    return !ctx->user_ip6[0] && !ctx->user_ip6[1] &&
           !ctx->user_ip6[2] && ctx->user_ip6[3] == bpf_htonl(1);
}

static __always_inline void read_destination(struct bpf_sock_addr *ctx,
                                             struct destination *d, int v6)
{
    d->cookie = bpf_get_socket_cookie(ctx);
    d->created = bpf_ktime_get_ns();
    d->family = v6 ? AF_INET6 : AF_INET;
    d->port = bpf_ntohs(ctx->user_port);
    if (v6) {
#pragma unroll
        for (int i = 0; i < 4; i++)
            d->address[i] = *(volatile __u32 *)&ctx->user_ip6[i];
    } else
        d->address[0] = ctx->user_ip4;
}

static __always_inline void to_local(struct bpf_sock_addr *ctx, int v6, __u16 port)
{
    if (v6) {
        *(volatile __u32 *)&ctx->user_ip6[0] = 0;
        *(volatile __u32 *)&ctx->user_ip6[1] = 0;
        *(volatile __u32 *)&ctx->user_ip6[2] = 0;
        *(volatile __u32 *)&ctx->user_ip6[3] = bpf_htonl(1);
    } else {
        ctx->user_ip4 = bpf_htonl(0x7f000001);
    }
    ctx->user_port = bpf_htons(port);
}

static __always_inline int dns_slot(struct bpf_sock_addr *ctx, int v6)
{
    struct udp_state *s = bpf_sk_storage_get(&udp_storage, ctx->sk, 0,
                                            BPF_SK_STORAGE_GET_F_CREATE);
    if (!s)
        return -1;
    struct destination d = {};
    read_destination(ctx, &d, v6);
    int empty = -1;
#pragma unroll
    for (int i = 0; i < DNS_SLOTS; i++) {
        struct destination *p = &s->peers[i];
        if (!p->family && empty < 0)
            empty = i;
        if (p->family == d.family && p->port == d.port &&
            !__builtin_memcmp(p->address, d.address, sizeof(d.address)))
            return i;
    }
    if (empty < 0)
        return -1;
    s->peers[empty] = d;
    return empty;
}

static __always_inline int redirect(struct bpf_sock_addr *ctx, int v6, int sendmsg)
{
    __u16 port = bpf_ntohs(ctx->user_port);
    if (ctx->type == SOCK_DGRAM) {
        if (port != 53)
            return loopback(ctx, v6); // Arbitrary external UDP is unsupported.
        int slot = dns_slot(ctx, v6);
        if (slot < 0)
            return 0;
        to_local(ctx, v6, dns_base + slot);
        return 1;
    }
    if (sendmsg || ctx->type != SOCK_STREAM)
        return 0;
    if (port != 53 && loopback(ctx, v6))
        return 1; // Preserve existing Realm loopback adapters.
    struct tcp_state *s = bpf_sk_storage_get(&tcp_storage, ctx->sk, 0,
                                            BPF_SK_STORAGE_GET_F_CREATE);
    if (!s)
        return 0;
    __builtin_memset(s, 0, sizeof(*s));
    read_destination(ctx, &s->original, v6);
    to_local(ctx, v6, tcp_port);
    return 1;
}

SEC("cgroup/connect4")
int connect4(struct bpf_sock_addr *ctx) { return redirect(ctx, 0, 0); }
SEC("cgroup/connect6")
int connect6(struct bpf_sock_addr *ctx) { return redirect(ctx, 1, 0); }
SEC("cgroup/sendmsg4")
int sendmsg4(struct bpf_sock_addr *ctx) { return redirect(ctx, 0, 1); }
SEC("cgroup/sendmsg6")
int sendmsg6(struct bpf_sock_addr *ctx) { return redirect(ctx, 1, 1); }

// The source port exists once TCP is established. Publish a reverse tuple
// which the accepted proxy socket can look up. An accepted socket has its own
// cookie; confusing the client and accepted cookies would lose the destination.
SEC("sockops")
int handle_sockops(struct bpf_sock_ops *ctx)
{
    if (!ctx->sk)
        return 1;
    struct tcp_state *s = bpf_sk_storage_get(&tcp_storage, ctx->sk, 0, 0);
    if (!s)
        return 1;
    if (ctx->op == BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB) {
        s->key.netns = bpf_get_netns_cookie(ctx);
        s->key.family = ctx->family;
        s->key.source_port = ctx->local_port;
        s->key.proxy_port = bpf_ntohl(ctx->remote_port);
        if (ctx->family == AF_INET)
            s->key.source[0] = ctx->local_ip4;
        else {
#pragma unroll
            for (int i = 0; i < 4; i++)
                s->key.source[i] = *(volatile __u32 *)&ctx->local_ip6[i];
        }
        if (!bpf_map_update_elem(&connections, &s->key, &s->original, BPF_ANY))
            s->tracked = 1;
        bpf_sock_ops_cb_flags_set(ctx, BPF_SOCK_OPS_STATE_CB_FLAG);
    } else if (ctx->op == BPF_SOCK_OPS_STATE_CB && ctx->args[1] == 7 && s->tracked) {
        struct destination *d = bpf_map_lookup_elem(&connections, &s->key);
        if (d && d->cookie == s->original.cookie)
            bpf_map_delete_elem(&connections, &s->key);
    }
    return 1;
}

static __always_inline int restore(struct bpf_sock_addr *ctx, int v6, int udp_only)
{
    struct destination *d = 0;
    if (ctx->type == SOCK_DGRAM) {
        __u16 port = bpf_ntohs(ctx->user_port);
        if (port < dns_base || port >= dns_base + DNS_SLOTS || !loopback(ctx, v6))
            return 1;
        struct udp_state *s = bpf_sk_storage_get(&udp_storage, ctx->sk, 0, 0);
        if (!s)
            return 1;
        __u32 slot = port - dns_base;
        if (slot >= DNS_SLOTS)
            return 0;
        d = &s->peers[slot];
    } else if (!udp_only && ctx->type == SOCK_STREAM) {
        struct tcp_state *s = bpf_sk_storage_get(&tcp_storage, ctx->sk, 0, 0);
        if (s)
            d = &s->original;
    }
    if (!d || d->family != (v6 ? AF_INET6 : AF_INET))
        return 1;
    ctx->user_port = bpf_htons(d->port);
    if (v6) {
#pragma unroll
        for (int i = 0; i < 4; i++)
            *(volatile __u32 *)&ctx->user_ip6[i] = d->address[i];
    } else
        ctx->user_ip4 = d->address[0];
    return 1;
}

SEC("cgroup/getpeername4")
int getpeer4(struct bpf_sock_addr *ctx) { return restore(ctx, 0, 0); }
SEC("cgroup/getpeername6")
int getpeer6(struct bpf_sock_addr *ctx) { return restore(ctx, 1, 0); }
SEC("cgroup/recvmsg4")
int recvmsg4(struct bpf_sock_addr *ctx) { return restore(ctx, 0, 1); }
SEC("cgroup/recvmsg6")
int recvmsg6(struct bpf_sock_addr *ctx) { return restore(ctx, 1, 1); }

char LICENSE[] SEC("license") = "GPL";
