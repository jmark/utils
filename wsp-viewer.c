#include <gtk/gtk.h>
#include <gdk/gdk.h>

#include <stdio.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <err.h>

#include <jansson.h>

#include "libi3.h"
#include <i3/ipc.h>

#include <glib-1.2/glib.h>

static char *socket_path;

/*
 * Having verboselog() and errorlog() is necessary when using libi3.
 *
 */
void verboselog(char *fmt, ...) {
    va_list args;

    va_start(args, fmt);
    vfprintf(stdout, fmt, args);
    va_end(args);
}

void errorlog(char *fmt, ...) {
    va_list args;

    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
}

static char *last_key = NULL;

typedef struct reply_t {
    bool success;
    char *error;
    char *input;
    char *errorposition;
} reply_t;

static reply_t last_reply;

static int reply_boolean_cb(void *params, int val) {
    if (strcmp(last_key, "success") == 0)
        last_reply.success = val;
    return 1;
}



int timer ( GtkWindow *window )
{
    gtk_window_close(window);
    return 0;
}

int main ( int argc, char *argv[] )
{

    GtkWidget *window;
    gtk_init (&argc, &argv);

    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

    char *wsp[] = {"1\0","2\0","3\0"};
  
    char *css = "\
    GtkWindow {\
        background-color: black;\
    }\
    GtkLabel {\
        font: Monospace 40;\
        color: white;\
    }\
    GtkLabel#current {\
        color: blue;\
        background-color: orange;\
    }";

    GtkCssProvider * cssP;
    cssP = gtk_css_provider_new();

    gtk_style_context_add_provider_for_screen (
        gdk_screen_get_default(),
        (GtkStyleProvider*) cssP,
        GTK_STYLE_PROVIDER_PRIORITY_USER);

    gtk_css_provider_load_from_data (cssP, css, -1, 0);

    GtkWidget *box;
    box = gtk_box_new ( GTK_ORIENTATION_HORIZONTAL, 2 );

    socket_path = getenv("I3SOCK");
    int message_type = I3_IPC_MESSAGE_TYPE_GET_WORKSPACES;
    char *payload = "";
    bool quiet = false;

    if (socket_path == NULL)
        socket_path = root_atom_contents("I3_SOCKET_PATH", NULL, 0);

    /* Fall back to the default socket path */
    if (socket_path == NULL)
        socket_path = sstrdup("/tmp/i3-ipc.sock");

    int sockfd = socket(AF_LOCAL, SOCK_STREAM, 0);
    if (sockfd == -1)
        err(EXIT_FAILURE, "Could not create socket");

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(struct sockaddr_un));
    addr.sun_family = AF_LOCAL;
    strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path) - 1);
    if (connect(sockfd, (const struct sockaddr*)&addr, sizeof(struct sockaddr_un)) < 0)
        err(EXIT_FAILURE, "Could not connect to i3 on socket \"%s\"", socket_path);

    if (ipc_send_message(sockfd, strlen(payload), message_type, (uint8_t*)payload) == -1)
        err(EXIT_FAILURE, "IPC: write()");

    if (quiet)
        return 0;

    uint32_t reply_length;
    uint32_t reply_type;
    uint8_t *reply;
    int ret;
    if ((ret = ipc_recv_message(sockfd, &reply_type, &reply_length, &reply)) != 0) {
        if (ret == -1)
            err(EXIT_FAILURE, "IPC: read()");
        exit(1);
    }
    close(sockfd);
    if (reply_type != message_type)
        errx(EXIT_FAILURE, "IPC: Received reply of type %d but expected %d", reply_type, message_type);

    json_t *root;
    json_error_t error;

    root = json_loadb(reply, reply_length, 0, &error);

    if(!root)
    {
        fprintf(stderr, "error: on line %d: %s\n", error.line, error.text);
        printf("%.*s\n\n", reply_length, reply);
        return 1;
    }

    if(!json_is_array(root))
    {
        fprintf(stderr, "error: root is not an array\n");
        json_decref(root);
        return 1;
    }

    int i;
    for(i = 0; i < json_array_size(root); i++)
    {
        json_t *data, *name, *focused;
        const char *message_text;

        data = json_array_get(root, i);
        if(!json_is_object(data))
        {
            fprintf(stderr, "error: commit data %d is not an object\n", i + 1);
            json_decref(root);
            return 1;
        }

        name = json_object_get(data, "name");
        if(!json_is_string(name))
        {
            fprintf(stderr, "error: commit %d: sha is not a string\n", i + 1);
            json_decref(root);
            return 1;
        }

        focused = json_object_get(data, "focused");
        if(!json_is_boolean(focused))
        {
            fprintf(stderr, "error: commit %d: sha is not a string\n", i + 1);
            json_decref(root);
            return 1;
        }

        GtkWidget *label;
        label = gtk_label_new ( json_string_value(name) );

        if (json_is_true(focused))
        {
            //printf ( "%s -> 1, ", json_string_value(name) );
            gtk_widget_set_name ( label, "current" );
        }
        // else
        // {
        //     printf ( "%s -> 0, ", json_string_value(name) );
        // }

        gtk_box_pack_start ((GtkBox*)box, label, 1, 1, 1);
    }

    //printf("%.*s\n", reply_length, reply);
    
    json_decref(root);

    gtk_container_add(GTK_CONTAINER(window), box);

    g_signal_connect (window, "destroy", G_CALLBACK (gtk_main_quit), NULL);
    gtk_widget_show_all (window);

    g_timeout_add ( 500, (GSourceFunc)timer, window );

    gtk_window_move((GtkWindow*)window, 1, 1);
    gtk_main ();
    
    free(reply);

    return 0;
}
