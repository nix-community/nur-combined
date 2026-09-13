{ self, inputs, ... }:
{
  flake.modules.nixos."bird/abhoth" =
    { config, ... }:
    {
      imports = [
        self.modules.nixos.bird
        inputs.autopeer.nixosModules.default
      ];
      services.autopeer = {
        enable = true;
        localAsn = 4242420291;
        port = 9341;
        birdConfDir = "/var/lib/autopeer";
        environmentFile = config.vaultix.secrets."autopeer".path;
      };
      vaultix.secrets = {
        autopeer = { };
        babel-auth = {
          owner = "bird";
        };
      };
      bird = {
        config = ''
          include "${config.vaultix.secrets.babel-auth.path}";

          ipv6 table dn42_v6;

          define DN42_V6_RANGE = [ fd00::/8+ ];

          protocol direct direct_dn42 {
            ipv6 { table dn42_v6; };
            interface "dn42-dummy";
          }          

          # 3. 入站过滤器 (from_dn42)
          filter from_dn42 {
            # 拒绝非法掩码长度（DN42 规范：通常不接受小于 /44 或大于 /64 的路由，过滤防误操作）
            if (net.len < 44) || (net.len > 64) then reject;
            
            # 防环路：拒绝别人把你自己的前缀宣告给你
            if net ~ DN42_FIELD then reject;
            
            # 基础校验：仅接收 DN42 ULA 范围内的合法路由
            # （未来如果你打算做 ROA/RPKI，相关的校验逻辑也会加在这里）
            if net ~ DN42_V6_RANGE then accept;
            
            reject;
          }

          # 4. 出站过滤器 (to_dn42)
          filter to_dn42 {
            # 宣告你自己的 DN42 网段
            if source = RTS_DEVICE && net ~ DN42_FIELD then accept;
            
            # 如果你允许做 Transit (允许你的 Peer A 通过你访问 Peer B)，取消下方注释
            if source = RTS_BGP then accept; 
            
            reject;
          }

          # 5. 表间互通管道：将 DN42 路由引入你的主网络
          protocol pipe pipe_dn42 {
            table master6;
            peer table dn42_v6;
            
            import filter {
              # 将 DN42 的路由拉进 master6，供内核和 Babel 使用
              if net ~ DN42_V6_RANGE then accept;
              reject;
            };
            
            # 从 master6 侧不向 dn42_v6 输出任何东西
            # (因为你在 static_dn42 里已经独立生成了宣告前缀)
            export none; 
          }

          include "/var/lib/autopeer/*.conf";
        '';
      };
    };
}
