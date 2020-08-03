#!/usr/bin/env bash
#Print pretty pineapple text and prepare environment
rm -rf /tmp/pineapple
mkdir -p /tmp/pineapple && cd /tmp/pineapple
base64 -d <<<"ICAgICAgICAgICAvJCQgICAgICAgICAgIC8kJCQkJCQkJCAgLyQkJCQkJCAgICAgICAgICAgICAg
ICAgICAgICAvJCQgICAgICAgICAgCiAgICAgICAgICB8X18vICAgICAgICAgIHwgJCRfX19fXy8g
LyQkX18gICQkICAgICAgICAgICAgICAgICAgICB8ICQkICAgICAgICAgIAogIC8kJCQkJCQgIC8k
JCAvJCQkJCQkJCB8ICQkICAgICAgfCAkJCAgXCAkJCAgLyQkJCQkJCAgIC8kJCQkJCQgfCAkJCAg
LyQkJCQkJCAKIC8kJF9fICAkJHwgJCR8ICQkX18gICQkfCAkJCQkJCAgIHwgJCQkJCQkJCQgLyQk
X18gICQkIC8kJF9fICAkJHwgJCQgLyQkX18gICQkCnwgJCQgIFwgJCR8ICQkfCAkJCAgXCAkJHwg
JCRfXy8gICB8ICQkX18gICQkfCAkJCAgXCAkJHwgJCQgIFwgJCR8ICQkfCAkJCQkJCQkJAp8ICQk
ICB8ICQkfCAkJHwgJCQgIHwgJCR8ICQkICAgICAgfCAkJCAgfCAkJHwgJCQgIHwgJCR8ICQkICB8
ICQkfCAkJHwgJCRfX19fXy8KfCAkJCQkJCQkL3wgJCR8ICQkICB8ICQkfCAkJCQkJCQkJHwgJCQg
IHwgJCR8ICQkJCQkJCQvfCAkJCQkJCQkL3wgJCR8ICAkJCQkJCQkCnwgJCRfX19fLyB8X18vfF9f
LyAgfF9fL3xfX19fX19fXy98X18vICB8X18vfCAkJF9fX18vIHwgJCRfX19fLyB8X18vIFxfX19f
X19fLwp8ICQkICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwgJCQgICAg
ICB8ICQkICAgICAgICAgICAgICAgICAgICAKfCAkJCAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICB8ICQkICAgICAgfCAkJCAgICAgICAgICAgICAgICAgICAgCnxfXy8gICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfF9fLyAgICAgIHxfXy8gICAgICAg
ICAgICAgICAgIA=="
printf "\n"
printf "on pizza\n"
printf "Brought to you by EmuWorld!\n"
#Download and save links currently listed on PinEApple site
curl -s https://raw.githubusercontent.com/pineappleEA/pineappleEA.github.io/master/index.html | sed -e '0,/^			<!--link-goes-here-->$/d' -e '/div/q;p'| head -n -2 > version.txt
#Print current version and take user input
function prompt
{
printf "Latest version is "
latest=$(head -n 1 version.txt | grep -o 'EA .*' | tr -d '</a><br>' | sed 's/[^0-9]*//g')
printf $latest
printf "\n"
printf " [1] Download it \n [2] Download an older version \n [3] Uninstall \n [4] To display Discord Invite\n or anything else to exit.\nOption:"
read option <&1
#execute the given command
if [ "$option" = "1" ]; then
    title=$latest
	curl -s $(head -n 1 version.txt | grep -o 'https.*7z') > version.txt
elif [ "$option" = "2" ]; then
	printf "Available versions:\n"
	uniq version.txt | grep -o 'EA .*' | tr -d '</a><br>' | sed -e ':a;N;$!ba;s/\n/,/g' -e 's/\EA //g'
	printf "Choose version number:"
	read version <&1
	title=$version
	curl -s $(grep "YuzuEA-$version" version.txt | grep -o 'https.*7z') > version.txt
elif [ "$option" = "3" ]; then
	printf "\nUninstalling...\n"
	sudo rm /usr/local/bin/yuzu
	sudo rm /usr/share/icons/hicolor/scalable/apps/yuzu.svg
	sudo rm /usr/share/pixmaps/yuzu.svg
	sudo rm /usr/share/applications/yuzu.desktop
	sudo update-desktop-database
	printf "Uninstalled successfully\n"
	exit
elif [ "$option" = "4" ]; then
	printf "Discord Invite:\n"
	base64 -d <<<"aHR0cHM6Ly9kaXNjb3JkLmdnL3dVZUJBc3Y="
	printf "\n"
	sleep 2s
	prompt
else
	printf "Exiting...\n"
	exit
fi
}
prompt
#Download and unzip given version
if ! [ -x "$(command -v aria2c)" ]; then
	wget $(cat version.txt | grep -o 'https://cdn-.*.7z' | head -n 1)
else
	aria2c -x 6 -s 6 $(cat version.txt | grep -o 'https://cdn-.*.7z' | head -n 1)
fi
if [ $? -ne 0 ]; then
    printf "Download failed!\n"
    printf "If you are in Italy or Iran, please use a VPN in another country\n"
    printf "otherwise, please try again in a few minutes\n"
    exit
fi
7z x Yuzu* yuzu-windows-msvc-early-access/yuzu-windows-msvc-source-*
cd yuzu-windows-msvc-early-access
tar -xf yuzu-windows-msvc-source-*
rm yuzu-windows-msvc-source-*.tar.xz 
#Compilation
cd $(ls -d yuzu-windows-msvc-source-*)
find -path ./dist -prune -o -type f -exec sed -i 's/\r$//' {} ';'
wget https://raw.githubusercontent.com/PineappleEA/Pineapple-Linux/master/inject-git-info.patch
patch -p1 < inject-git-info.patch
msvc=$(echo "${PWD##*/}"|sed 's/.*-//')
mkdir -p build && cd build
cmake .. -GNinja -DTITLE_BAR_FORMAT_IDLE="yuzu Early Access $title" -DTITLE_BAR_FORMAT_RUNNING="yuzu Early Access $title | {3}" -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=ON -DGIT_BRANCH="HEAD" -DGIT_DESC="$msvc" -DUSE_DISCORD_PRESENCE=ON -DYUZU_USE_QT_WEB_ENGINE=ON
ninja -j $(nproc)
printf '\e[1;32m%-6s\e[m' "Compilation completed, do you wish to install it[y/n]?:"
read install <&1
#Save compiler output to ~/earlyaccess/yuzu and cleanup /tmp if user doesn't want to install
if [ "$install" = "n" ]; then
	mkdir -p ~/earlyaccess
	mv bin/yuzu ~/earlyaccess/yuzu
	cd ~/earlyaccess/yuzu
	rm -rf /tmp/pineapple/*
	printf '\e[1;32m%-6s\e[m' "The binary sits at ~/earlyaccess/yuzu."
	printf "\n"
	exit
else
    :
fi
#Install yuzu and cleanup /tmp
sudo mv bin/yuzu /usr/local/bin/yuzu
cd /usr/share/pixmaps
rm -rf /tmp/pineapple/*
FILE=/usr/share/applications/yuzu.desktop
if [[ -f "$FILE" ]]; then
    :
else
	sudo sh -c "curl -s https://raw.githubusercontent.com/pineappleEA/Pineapple-Linux/master/yuzu.svg > yuzu.svg"
	sudo cp /usr/share/pixmaps/yuzu.svg /usr/share/icons/hicolor/scalable/apps/yuzu.svg
	sudo sh -c "curl -s https://raw.githubusercontent.com/pineappleEA/Pineapple-Linux/master/yuzu.desktop > /usr/share/applications/yuzu.desktop"
	sudo update-desktop-database
fi
printf '\e[1;32m%-6s\e[m' "Installation completed. Use the command yuzu or run it from your launcher."
printf "\n"
