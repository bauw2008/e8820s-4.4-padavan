#!/bin/sh

mount -t proc proc /proc
mount -t sysfs sysfs /sys
[ -d /proc/bus/usb ] && mount -t usbfs usbfs /proc/bus/usb

size_tmp="28M"
size_var="4M"
size_etc="4M"

if [ "$1" == "-4" ] ; then
	size_etc="4M"
fi
if [ "$1" == "-8" ] ; then
	size_etc="4M"
fi
if [ "$1" == "-16" ] ; then
	size_etc="4M"
fi
if [ "$1" == "-32" ] ; then
	size_etc="20M"
fi

if [ "$2" == "-32" ] ; then
	size_tmp="8M"
fi
if [ "$2" == "-64" ] ; then
	size_tmp="28M"
fi
if [ "$2" == "-128" ] ; then
	size_tmp="40M"
	if [ "$1" == "-NAND" ] ; then
		size_etc="20M"
	fi
fi
if [ "$2" == "-256" ] ; then
	size_tmp="40M"
	if [ "$1" == "-NAND" ] ; then
		size_tmp="80M"
		size_etc="70M"
	fi
fi
if [ "$2" == "-512" ] ; then
	size_tmp="40M"
	if [ "$1" == "-NAND" ] ; then
		size_tmp="80M"
		size_etc="70M"
	fi
fi


mount -t tmpfs tmpfs /dev   -o size=8K
mount -t tmpfs tmpfs /etc   -o size=$size_etc,noatime
mount -t tmpfs tmpfs /home  -o size=1M
mount -t tmpfs tmpfs /media -o size=8K
mount -t tmpfs tmpfs /mnt   -o size=8K
mount -t tmpfs tmpfs /tmp   -o size=$size_tmp
mount -t tmpfs tmpfs /var   -o size=$size_var

if [ ! -z "$(cat /proc/mtd | grep \"Storage\")" ] ; then
# Storage (KB)
size_storage=$(($(printf "%d" "0x""$(cat /proc/mtd | grep \"Storage\" | awk -F'\ ' '{print $2}')") / 1000 ))
size_free=$(free | grep Mem: | awk -F'\ ' '{print $2}')
size_etc=$(($size_storage + 5000 ))
[ ! -z "$size_etc" ] && [ ! -z "$size_free" ] && [ "$size_free" -gt "$size_etc" ] && mount -o remount,size="$size_etc"K,noatime tmpfs /etc
fi

mkdir /dev/pts
mount -t devpts devpts /dev/pts

ln -sf /etc_ro/mdev.conf /etc/mdev.conf
mdev -s

# create dirs
mkdir -p -m 777 /var/lock
mkdir -p -m 777 /var/locks
mkdir -p -m 777 /var/private
mkdir -p -m 700 /var/empty
mkdir -p -m 777 /var/lib
mkdir -p -m 777 /var/log
mkdir -p -m 777 /var/run
mkdir -p -m 777 /var/tmp
mkdir -p -m 777 /var/spool
mkdir -p -m 777 /var/lib/misc
mkdir -p -m 777 /var/state
mkdir -p -m 777 /var/state/parport
mkdir -p -m 777 /var/state/parport/svr_statue
mkdir -p -m 777 /tmp/var
mkdir -p -m 777 /tmp/hashes
mkdir -p -m 777 /tmp/modem
mkdir -p -m 777 /tmp/rc_notification
mkdir -p -m 777 /tmp/rc_action_incomplete
mkdir -p -m 700 /home/root
mkdir -p -m 700 /home/root/.ssh
mkdir -p -m 755 /etc/storage
mkdir -p -m 755 /etc/ssl
mkdir -p -m 755 /etc/Wireless
mkdir -p -m 750 /etc/Wireless/RT2860
mkdir -p -m 750 /etc/Wireless/iNIC
mkdir -p -m 777 /etc/storage/lib
mkdir -p -m 777 /etc/storage/bin
mkdir -p -m 777 /etc/storage/tinyproxy

# extract storage files
mtd_storage.sh load

touch /etc/resolv.conf
cp -f /etc_ro/ld.so.cache /etc

if [ -f /etc_ro/openssl.cnf ]; then
	cp -f /etc_ro/openssl.cnf /etc/ssl
fi

# create symlinks
ln -sf /home/root /home/admin
ln -sf /proc/mounts /etc/mtab
ln -sf /etc_ro/ethertypes /etc/ethertypes
ln -sf /etc_ro/netconfig /etc/netconfig
ln -sf /etc_ro/protocols /etc/protocols
ln -sf /etc_ro/services /etc/services
ln -sf /etc_ro/shells /etc/shells
ln -sf /etc_ro/profile /etc/profile
ln -sf /etc_ro/e2fsck.conf /etc/e2fsck.conf
ln -sf /etc_ro/ipkg.conf /etc/ipkg.conf
ln -sf /etc_ro/ld.so.conf /etc/ld.so.conf
{
#ln -s /etc_ro/basedomain.txt /etc/storage/basedomain.txt
[ ! -s /etc/storage/china_ip_list.txt ] && [ -s /etc_ro/china_ip_list.tgz ] && { tar -xzvf /etc_ro/china_ip_list.tgz -C /tmp ; ln -sf /tmp/china_ip_list.txt /etc/storage/china_ip_list.txt ; }
[ ! -s /etc/storage/basedomain.txt ] && [ -s /etc_ro/basedomain.tgz ] && { tar -xzvf /etc_ro/basedomain.tgz -C /tmp ; ln -sf /tmp/basedomain.txt /etc/storage/basedomain.txt ; }
#ln -s /etc_ro/ruijie_4.44.mpf /etc/storage/ruijie_4.44.mpf
ln -sf /etc/storage/PhMain.ini /etc/PhMain.ini &
ln -sf /etc/storage/init.status /etc/init.status &
[ -s /etc_ro/sxplugin.tgz ] && tar -xzvf /etc_ro/sxplugin.tgz -C /tmp
[ -s /etc_ro/www_asp.tgz ] && { tar -xzvf /etc_ro/www_asp.tgz -C /tmp ;  chmod 666 /tmp/www_asp -R ; }
[ ! -s /etc/storage/script/init.sh ] && [ -s /etc_ro/script.tgz ] && tar -xzvf /etc_ro/script.tgz -C /etc/storage/
[ -s /etc/storage/script/init.sh ] && chmod 777 /etc/storage/script -R
[ ! -s /etc/storage/www_sh/menu_title.sh ] && [ -s /etc_ro/www_sh.tgz ] && tar -xzvf /etc_ro/www_sh.tgz -C /etc/storage/
[ -s /etc/storage/www_sh/menu_title.sh ] && chmod 777 /etc/storage/www_sh -R
#[ ! -s /etc/storage/bin/daydayup ] && [ -s /etc_ro/daydayup ] && ln -sf /etc_ro/daydayup /etc/storage/bin/daydayup
} &

# tune linux kernel
echo 65536        > /proc/sys/fs/file-max
echo "1024 65535" > /proc/sys/net/ipv4/ip_local_port_range
ulimit -HSn 65536

# fill storage
mtd_storage.sh fill

# prepare ssh authorized_keys
if [ -f /etc/storage/authorized_keys ] ; then
	cp -f /etc/storage/authorized_keys /home/root/.ssh
	chmod 600 /home/root/.ssh/authorized_keys
fi

# perform start script
if [ -x /etc/storage/start_script.sh ] ; then
	/etc/storage/start_script.sh
fi

