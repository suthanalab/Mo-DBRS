#ifndef RNS_SERVER_H__
#define RNS_SERVER_H__

#include <sys/socket.h>
#include <netinet/in.h>

#define SERVER_IP_ADDRESS			"192.168.0.5"
#define SERVER_PORT				    8080


int server_open(char* ipAddress, unsigned int portNumber);
int server_close();

#endif /* RNS_SERVER_H__ */
