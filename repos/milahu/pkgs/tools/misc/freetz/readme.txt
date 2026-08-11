nix-build . -A freetz-tools

git clone --depth=1 https://github.com/Freetz-NG/freetz-ng

cd freetz-ng

mv tools tools_bak

ln -s ../result/opt/freetz/tools .

./tools/kconfig/mconf config/.cache.in || ./tools/kconfig/mconf config/Config.in
