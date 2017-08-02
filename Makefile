gcc wsp-viewer.c -o wsp-viewer.bin `pkg-config --cflags --libs gtk+-3.0` -I. -L /tmp/i3-4.7.2 -li3 -ljansson -lm -lxcb -lxcb-util -lglib
