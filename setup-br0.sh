/usr/bin/sudo systemctl stop dhcpcd@enp3s0
/usr/bin/sudo brctl addbr br0
/usr/bin/sudo brctl addif br0 enp3s0
/usr/bin/sudo ip link set up enp3s0
/usr/bin/sudo ip link set up br0
/usr/bin/sudo systemctl start dhcpcd@br0
/usr/bin/sudo systemctl status dhcpcd@br0
