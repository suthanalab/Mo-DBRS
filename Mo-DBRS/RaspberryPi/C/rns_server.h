#ifndef RNS_SERVER_H__
#define RNS_SERVER_H__

#include <sys/socket.h>
#include <netinet/in.h>

typedef struct Param
{
    char*   ip_address;
    int     port;
    char*   dev_port;
    int     rns_device;
} Parameters;


int server_open(Parameters param);
int server_join();

#endif /* RNS_SERVER_H__ */
