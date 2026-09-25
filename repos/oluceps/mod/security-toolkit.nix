{
  flake.modules.nixos.security-toolkit =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    with lib;
    {
      environment.systemPackages = with pkgs; [
        # === 信息收集 ===
        pi-coding-agent
        nmap
        masscan
        amass
        gobuster
        ffuf
        dnsutils

        # === 漏洞分析与自动化扫描 (纯 CLI) ===
        metasploit # 推荐使用 msfconsole
        sqlmap
        nikto
        nuclei # 极速、基于模板的漏洞扫描器
        httpx # 多用途高并发 HTTP 探测工具

        # === 网络流量与数据包分析 (终端 TUI) ===
        wireshark-cli # 提供 tshark 用于抓包
        termshark # tshark 的图形化终端(TUI)前端
        tcpdump
        aircrack-ng
        bettercap

        # === Web 拦截代理 ===
        mitmproxy # 强大的交互式终端 HTTP/HTTPS 拦截代理

        # === 逆向与取证 ===
        binwalk
        radare2
        sleuthkit

        # === 密码审计 ===
        hashcat
        john

        # === 网络转发与终端复用 ===
        netcat-gnu
      ];
    };
}
