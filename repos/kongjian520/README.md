# KongJianNUR

## 现有的构建：

|项目|版本号|
|---|---|
|yakit|1.4.4-1017|
|tssh|0.1.23|

## 如何使用

临时测试使用：
```nix
nix run .#<你想要的包名>   
```

安装到全局中：
```nix 
nix profile install .#<你想要的包名>
```