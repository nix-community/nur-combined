# shellcheck disable=SC2317
# 设置客户端环境变量的钩子脚本
postHook() {
    # 添加二进制目录到PATH
    if [ -d "@out@/bin" ]; then
        export PATH="@out@/bin:$PATH"
    fi

    # 设置应用特定环境变量（如果需要）
    export HN_CLIENT_HOME="@out@"
}
postHooks+=(postHook)
