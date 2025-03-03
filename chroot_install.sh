pwd

if [ -f /root/local_config.sh ]; then
    source /root/local_config.sh
else
    echo "local_config.sh not found, running config.sh"
    source /root/config.sh
fi

mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

# Update apt sources
apt-get update
apt-get -y upgrade

# Install packages
apt-get install -y \
    sudo \
    ubuntu-standard \
    casper \
    discover \
    laptop-detect \
    os-prober \
    network-manager \
    resolvconf \
    net-tools \
    wireless-tools \
    wpagui \
    locales \
    grub-common \
    grub-gfxpayload-lists \
    grub-pc \
    grub-pc-bin \
    grub2-common \
    gpg \
    vlc \
    vlc-plugin-access-extra \
    ffmpeg \
    python3-tk \
    p7zip-full \
    tinc

# Install Chrome to avoid using Firefox snap. Firefox snap can't read stuffs not in ~/
mkdir /tmp/chrome-download/
wget -qO /tmp/chrome-download/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i /tmp/chrome-download/chrome.deb
rm -r /tmp/chrome-download

# Reconfigure network-manager
cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF

# Create file /etc/modprobe.d/network.conf for enabling drivers for network cards from realtek
cat <<EOF > /etc/modprobe.d/network.conf
install r8169 /sbin/modprobe --ignore-install r8169
install rtw88 /sbin/modprobe --ignore-install rtw88
EOF

dpkg-reconfigure network-manager

# Clean up the chroot environment
truncate -s 0 /etc/machine-id

rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

apt-get clean
rm -rf /tmp/* ~/.bash_history
umount /proc
umount /sys
umount /dev/pts
export HISTSIZE=0

exit
