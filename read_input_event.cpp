# include <unistd.h>
# include <X11/Xlib.h>
# include <linux/input.h>
# include <iostream>
# include <fcntl.h>

using namespace std;

int main (int argc, char *argv[])
{
    struct input_event ev;
    int fd, rd, value, size = sizeof (struct input_event);
    char device[] = "/dev/input/event16";
 
    XEvent e;
    Display *d = XOpenDisplay(NULL);

    if(!d) return -1;

    if ((fd = open (device, O_RDONLY)) == -1)
        cerr << "cannot open device" << endl;

    int x_pad (0);
    int y_pad (0);

    while (1)
    {
        rd = read (fd, &ev, size);

        if (ev.type == 3 && (ev.code == 0 || ev.code == 1))
        {
            XQueryPointer(d, RootWindow(d, DefaultScreen(d)),
                    &e.xbutton.root, &e.xbutton.window,
                    &e.xbutton.x_root, &e.xbutton.y_root,
                    &e.xbutton.x, &e.xbutton.y,
                    &e.xbutton.state);

            if ( ev.value < 2 ) { continue; }

            if      ( ev.code == 0 ) { x_pad = ev.value; y_pad = -1; }
            else if ( ev.code == 1 ) { y_pad = ev.value; }

            if ( y_pad == -1 ) { continue; }

            cout << ev.time.tv_sec << ",";
            cout << ev.time.tv_usec << ",";
            cout << e.xbutton.x << ",";
            cout << e.xbutton.y << ",";
            cout << x_pad << ",";
            cout << y_pad << endl;
        }
    }
 
    XCloseDisplay(d);
    return 0;
}  
