#include "rns_server.h"

int main()
{
    Parameters param;
    param.ip_address = "192.168.0.5";
    param.port = 8080;
    param.dev_port = "/dev/ttyACM0";
    param.rns_device = 320;

    server_open(param);

    while(1)
    {

    }

    server_close();
    return 0;
}
