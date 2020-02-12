#include "rns_server.h"
#include "rns.h"
#include <arpa/inet.h>
#include <string.h>
#include <pthread.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <bcm2835.h>


typedef struct sServer
{
	int sockfd;
	int connfd;
	struct sockaddr_in address;
	struct sockaddr_in cli;
	bool connected;

} SocketServer;

static SocketServer* serv = NULL;
static bool serverEnabled;
static void* server_thread_function(void* pArgs);

const unsigned int TIME_FMT = strlen("2012-12-31 12:59:59.123456789") + 1;
static char timestr[TIME_FMT];
static struct timestamp;

int server_open(Parameters param)
{
	int retCode = 0;
    serv = (SocketServer*)malloc(sizeof(SocketServer));
	serv->sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if(serv->sockfd == -1)
	{
		printf("SOCKET SERVER: Socket creation failed.\n");
	}
	else
	{
		printf("SOCKET SERVER: Socket successfully created.\n");
	}
	bzero(&(serv->address), sizeof(serv->address));

	serv->address.sin_family 	= AF_INET;
	serv->address.sin_addr.s_addr 	= inet_addr(param.ipAddress);
	serv->address.sin_port 		    = htons(param.portNumber);

	if(bind(serv->sockfd, (struct sockaddr*)&(serv->address), sizeof(serv->address)) != 0)
	{
		printf("SOCKET SERVER: Socket bind failed\n");
	}



    rns_open(param.rns_device, param.serial_port);


	serverEnabled = true;
	serv->connected = false;

	if(pthread_create((&serverThread), NULL, server_thread_function, serv) != 0)
	{
		printf("SERVER: Thread create error\n");
		retCode = -1;
	}

	return retCode;
}

int server_close(SocketServer* serv)
{
	int retCode = 0;
	
	if(serverEnabled)
	{
		serverEnabled = false;
		pthread_join(serverThread, NULL);
	}

	close(serv->sockfd);
	return retCode;
}


static void* server_thread_function(void* pArgs)
{
	SocketServer* serv = (SocketServer*)pArgs;
	uint8_t recvBuffer[MAX_SERVER_RECEIVE_BUFFER_LENGTH];

	while(serverEnabled)
	{
		if(!serv->connected)
		{
			if(!listen(serv->sockfd, 1))
			{
				printf("SERVER: Listening...\n");
			}
			int len = sizeof(serv->cli);
			serv->connfd = accept(serv->sockfd, (struct sockaddr*)(&(serv->cli)), &len);
			if(serv->connfd < 0)
			{
				printf("SERVER: Accept failed\n");
			}
			serv->connected = true;
			printf("SOCKET SERVER: Connection established.\n");
		}

		while(serverEnabled & serv->connected)
		{
			bzero(recvBuffer, MAX_SERVER_RECEIVE_BUFFER_LENGTH);

			read(serv->connfd, recvBuffer, sizeof(recvBuffer));

			switch(recvBuffer[0])
			{
                case STORE_MSG:
                    send_store();
                    clock_gettime(CLOCK_REALTIME, &(timestamp);
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
                    printf("Store: %s", timestr);
                    break;
                case MARK_MSG:
                    send_mark();
                    clock_gettime(CLOCK_REALTIME, &(timestamp);
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
                    printf("Mark: %s", timestr);
                    break;
                case MAGNET_MSG:
                    send_magnet();
                    clock_gettime(CLOCK_REALTIME, &(timestamp);
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
                    printf("Magnet: %s", timestr);
                    break;
                case STIM_MSG:
                    send_stim();
                    clock_gettime(CLOCK_REALTIME, &(timestamp);
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
                    printf("Stim: %s", timestr);
                    break;
                case EXTERNAL_MAGNET_MSG:
                    send_external_magnet();
                    clock_gettime(CLOCK_REALTIME, &(timestamp);
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
                    printf("External magnet: %s", timestr);
                    break;
                case RESTART_MSG:
                    serv->connected = false;
                    clock_gettime(CLOCK_REALTIME, &(timestamp);
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
                    printf("Server restart: %s", timestr);
                    break;
                case CLOSE_MSG:

                    clock_gettime(CLOCK_REALTIME, &(timestamp);
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
                    printf("Server closing: %s", timestr);
                    serverEnabled = false;
					serv->connected = false;
                    break;

            }
        }
    }
}
