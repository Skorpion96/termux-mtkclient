#!/data/data/com.termux/files/usr/bin/bash
export DEBIAN_FRONTEND=nointeractive
pkg update && pkg upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef"
apt install libusb termux-api 
pkg install python2 python3 python-pip -y
if ! command -v git &> /dev/null; then
        pkg install git -y
        exit 1
fi
if ! command -v wget &> /dev/null; then
        pkg install wget -y
        exit 1
fi
git clone https://github.com/vaginessa/termux-mtkclient
mv ~/termux-mtkclient ~/.termux-mtkclient
cd ~/.termux-mtkclient
pip3 install -r requirements.txt
pip3 install .
cat << EOF > ~/.termux-mtkclient/MTKClient_Root_Menu.sh
#!/data/data/com.termux/files/usr/bin/bash
if [ "\$(whoami)" != "root" ]; then
    echo "This script must be run as the root user (UID 0) on termux."
    return 0
fi
PATH=/data/data/com.termux/files/usr/bin:\$PATH && cd /data/data/com.termux/files/home/.termux-mtkclient
# Function to display the menu
show_menu() {
    clear
    echo "========= MTKClient Rooting Menu ========="
    echo "Choose an option:"
    echo "1. Unlock Bootloader"
    echo "2. Lock Bootloader"
    echo "3. Dump stock boot and vbmeta"
    echo "4. Flash patched boot and blank vbmeta"
    echo "5. Dump Partitions"
    echo "6. Restore Partitions"
    echo "7. Bypass SLA, DAA and SBC"
    echo "8. Exit"
}

# Main menu loop
while true; do
    show_menu
    read -p "Enter your choice: " choice

    case \$choice in
        1)
            python mtk.py da seccfg unlock && read -p "Press [Enter] key to continue..."
            ;;
        2)
            python mtk.py da seccfg lock && read -p "Press [Enter] key to continue..."
            ;;
        3)
            python mtk.py r boot,vbmeta boot.img,vbmeta.img && echo "patch boot.img with magisk or apatch app and rename the resulting file to boot-patched.img, then copy it on mtkclient folder and run 4th option on MTKClient Root Menu" && read -p "Press [Enter] key to continue..."
            ;;
        4)
            python mtk.py w boot,vbmeta boot-patched.img,vbmeta.img.empty  && read -p "Press [Enter] key to continue..."
            ;;
        5)
           bash -c ~/.termux-mtkclient/Partitions_Backup.sh && read -p "Press [Enter] key to continue..."
            ;;
        6)
            bash -c ~/.termux-mtkclient/Partitions_Write.sh && read -p "Press [Enter] key to continue..."
            ;;   
        7)
            python3 mtk payload && read -p "Press [Enter] key to continue..."
            ;;      
        8)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            read -p "Press [Enter] key to continue..."
            ;;
    esac
done
EOF
ln -s ~/.termux-mtkclient/MTKClient_Root_Menu.sh /data/data/com.termux/files/usr/bin/mtkclient
wget https://github.com/Skorpion96/MTKClient-Root-Menu/raw/refs/heads/main/Linux/Partitions_Write.sh
wget https://github.com/Skorpion96/MTKClient-Root-Menu/raw/refs/heads/main/Linux/Partitions_Backup.sh
sed -i '1s|^#!/bin/bash|#!/data/data/com.termux/files/usr/bin/bash|' Partitions_Write.sh
sed -i '1s|^#!/bin/bash|#!/data/data/com.termux/files/usr/bin/bash|' Partitions_Backup.sh
chmod +x *.sh
pkg clean && cd ~
echo "Install completed, you can run mtkclient root menu by typing 'mtkclient'"
