# define  _GNU_SOURCE     /* To get defns of NI_MAXSERV and NI_MAXHOST */
# include <arpa/inet.h>
# include <sys/socket.h>
# include <netdb.h>
# include <ifaddrs.h>
# include <linux/if_link.h>

# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>
# include <time.h>
# include <string.h>

# define BUF_MAX 1024
# define MAX_CPU 128
 
# ifdef DEBUG
# define SLEEP 1
# else
# define SLEEP 10
# endif

unsigned long long int fields[10], total_tick[MAX_CPU], total_tick_old[MAX_CPU], idle[MAX_CPU], idle_old[MAX_CPU], del_total_tick[MAX_CPU], del_idle[MAX_CPU];
int update_cycle = 0, i, cpus = 0, count;
double usage;

inline void date ()
{
    time_t rawtime;
    struct tm * timeinfo;
    char buffer [80];
    
    time (&rawtime);
    timeinfo = localtime (&rawtime);
     
    strftime (buffer,sizeof(buffer),"%A, %d.%m.%Y | %R",timeinfo);
    printf ( "%s",buffer );
}

inline void IPv4 ()
{
    struct ifaddrs *ifaddr, *ifa;
    char host[NI_MAXHOST];

    if (getifaddrs(&ifaddr) == -1) printf (" %s ","getifaddrs failed");

    for (ifa = ifaddr ; ifa != NULL ; ifa = ifa->ifa_next )
    {
        if ( strcasecmp (ifa->ifa_name, "lo") == 0 ) continue;

        /* For an AF_INET* interface address, display the address */
        if ( ifa->ifa_addr && ifa->ifa_addr->sa_family == AF_INET )
        {
            int s = getnameinfo
                (
                    ifa->ifa_addr
                    ,sizeof(struct sockaddr_in)
                    ,host ,NI_MAXHOST
                    ,NULL ,0 ,NI_NUMERICHOST
                );

            if (s != 0) printf("getnameinfo() failed: %s\n", gai_strerror(s));

            printf ( "%s: %s | ",ifa->ifa_name, host );
        }
    }
    freeifaddrs(ifaddr);
}

inline int read_fields (FILE *fp, unsigned long long int *fields)
{
    int retval;
    char buffer[BUF_MAX];
 
    if (!fgets (buffer, BUF_MAX, fp))
    { perror ("Error"); }
    /* line starts with c and a string. This is to handle cpu, cpu[0-9]+ */
    retval = sscanf (buffer, "c%*s %Lu %Lu %Lu %Lu %Lu %Lu %Lu %Lu %Lu %Lu",
                              &fields[0], 
                              &fields[1], 
                              &fields[2], 
                              &fields[3], 
                              &fields[4], 
                              &fields[5], 
                              &fields[6], 
                              &fields[7], 
                              &fields[8], 
                              &fields[9]); 
    if (retval == 0)
    { return -1; }
    if (retval < 4) /* Atleast 4 fields is to be read */
    {
      fprintf (stderr, "Error reading /proc/stat cpu field\n");
      return 0;
    }
    return 1;
}

inline void ram_usage ( FILE *fp )
{
    char buffer[100];
    unsigned long int MemTotal = 0;
    unsigned long int MemFree  = 0;
    unsigned long int MemAvail = 0;
    
    fseek (fp, 0, SEEK_SET);
    fflush (fp);

    fgets  (buffer, sizeof(buffer), fp);
    sscanf (buffer, "%*s %Lu %*s", &MemTotal);
    fgets  (buffer, sizeof(buffer), fp);
    sscanf (buffer, "%*s %Lu %*s", &MemFree);
    fgets  (buffer, sizeof(buffer), fp);
    sscanf (buffer, "%*s %Lu %*s", &MemAvail);

    printf ("ram: %2.2f%% %d %d %d | ", (float)(MemTotal-MemAvail)/(float)MemTotal*100. ,(MemTotal-MemAvail)/1024 ,MemAvail/1024 ,MemTotal/1024);
}
 
inline void cpu_usage (FILE *fp)
{
    fseek (fp, 0, SEEK_SET);
    fflush (fp);
    
    printf ("cpu: ");
    for (count = 0; count < cpus; count++)
    {
        total_tick_old[count] = total_tick[count];
        idle_old[count] = idle[count];
     
        if (!read_fields (fp, fields)) printf ("problems reading /proc/stat fields" );
    
        for (i=0, total_tick[count] = 0; i<10; i++)
        { total_tick[count] += fields[i]; }
        idle[count] = fields[3];
    
        del_total_tick[count] = total_tick[count] - total_tick_old[count];
        del_idle[count] = idle[count] - idle_old[count];
    
        usage = ((del_total_tick[count] - del_idle[count]) / (double) del_total_tick[count]);
        if (count == 0)
        { /*printf ("Total CPU Usage: %3.2lf %%", percent_usage);*/ }
        else
        { printf ("%2.2f%% ", count - 1, usage*100); }
    }
    printf ("| ");
}

int main(void)
{
    FILE *fp_cpuinfo = fopen ("/proc/stat", "r");
    FILE *fp_meminfo = fopen ("/proc/meminfo", "r");

    while (read_fields (fp_cpuinfo, fields) != -1)
    {
        for (i=0, total_tick[cpus] = 0; i<10; i++) { total_tick[cpus] += fields[i]; }
        idle[cpus] = fields[3]; /* idle ticks index */
        cpus++;
    }

    while (1)
    {
        ram_usage(fp_meminfo);
        cpu_usage(fp_cpuinfo);
        IPv4();
        date();
        printf ("\n");
        fflush(stdout);
        (void) sleep(SLEEP);
    }

    return 0;
}
