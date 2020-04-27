#include "rns_server.h"
#include "rns.h"
#include <arpa/inet.h>
#include <string.h>
#include <pthread.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <time.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <bcm2835.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>


#define TIME_FMT 30 
#define MAX_SERVER_RECEIVE_BUFFER_LENGTH 1
#define STORE_MSG 		'r'
#define STIM_MSG 		's'
#define MARK_MSG 		't'
#define MAGNET_MSG 		'm'
#define EXTERNAL_MAGNET_MSG 	'e'
#define RESTART_MSG 		'u'
#define CLOSE_MSG 		'q'



typedef struct sServer
{
	int sockfd;
	int connfd;
	struct sockaddr_in address;
	struct sockaddr_in cli;
	bool connected;

} SocketServer;

static SocketServer* serv = NULL;
static pthread_t serverThread;
static bool serverEnabled;
static void* server_thread_function(void* pArgs);

static char timestr[TIME_FMT];
static struct timespec timestamp;



static volatile int keepRunning = 1;

void intHandler(int d) {
	printf("\nInterrupt closing...\n");
	serverEnabled = false;
	shutdown(serv->sockfd, SHUT_RD);
	close(serv->sockfd);
}

int timespec2str(char *buf, uint len, struct timespec *ts) {
    int ret;
    struct tm t;

    tzset();
    if (localtime_r(&(ts->tv_sec), &t) == NULL)
        return 1;

    ret = strftime(buf, len, "%F_%T", &t);
    if (ret == 0)
        return 2;
    len -= ret - 1;

    ret = snprintf(&buf[strlen(buf)], len, "_%09ld", ts->tv_nsec);
    if (ret >= len)
        return 3;

    return 0;
}


int server_open(Parameters param)
{
   	signal(SIGINT, intHandler);
	int retCode = 0;
    serv = (SocketServer*)malloc(sizeof(SocketServer));
	serv->sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if(serv->sockfd == -1)
	{
		printf("\n\nSOCKET SERVER: Socket creation failed.\n");
	}
	else
	{
		printf("\n\nSOCKET SERVER: Socket successfully created.\n");
	}
	bzero(&(serv->address), sizeof(serv->address));



	serv->address.sin_family 	= AF_INET;
	serv->address.sin_addr.s_addr 	= inet_addr(param.ip_address);
	serv->address.sin_port 		= htons(param.port);

	if(bind(serv->sockfd, (struct sockaddr*)&(serv->address), sizeof(serv->address)) != 0)
	{
		printf("\n\nSOCKET SERVER: Socket bind failed\n");
	}



    	rns_open(param.rns_device, param.dev_port);


	serverEnabled = true;
	serv->connected = false;

	if(pthread_create((&serverThread), NULL, server_thread_function, serv) != 0)
	{
		printf("\n\nSERVER: Thread create error\n");
		retCode = -1;
	}

	return retCode;
}

int server_join()
{
	int retCode = 0;
	

	pthread_join(serverThread, NULL);

	if(serverEnabled)
	{
		serverEnabled = false;
	}
	close(serv->sockfd);
	free(serv);
	return retCode;
}


int send_external_magnet()
{
	return 0;
}

static void* server_thread_function(void* pArgs)
{
	SocketServer* serv = (SocketServer*)pArgs;
	uint8_t recvBuffer[MAX_SERVER_RECEIVE_BUFFER_LENGTH];
	FILE * logFp = NULL;
	

	while(serverEnabled)
	{
		if(!serv->connected)
		{
			if(!listen(serv->sockfd, 1))
			{
				printf("\n\nSERVER: Listening...\n\n");
			}
			int len = sizeof(serv->cli);
			serv->connfd = accept(serv->sockfd, (struct sockaddr*)(&(serv->cli)), (socklen_t *)&len);
			if(serv->connfd < 0)
			{
				printf("\n\nSERVER: Accept failed\n\n");
				break;
			}

			struct stat st = {0};
			if (stat("./Log", &st) == -1) 
			{
 				mkdir("./Log", 0777);
			}

			clock_gettime(CLOCK_REALTIME, &(timestamp));
		        timespec2str(timestr, sizeof(timestr), &timestamp);                    

			char filename[40];

			sprintf(filename, "./Log/%s.log", timestr);

			logFp = fopen(filename, "w+");
		    	fprintf(logFp, "\nStart: %s", timestr);
			serv->connected = true;
			printf("\n\nSOCKET SERVER: Connection established.\n\n");
		}

		while(serverEnabled & serv->connected)
		{
			bzero(recvBuffer, MAX_SERVER_RECEIVE_BUFFER_LENGTH);

			read(serv->connfd, recvBuffer, sizeof(recvBuffer));


			switch(recvBuffer[0])
			{
                case STORE_MSG:
                    rns_send_store();
                    clock_gettime(CLOCK_REALTIME, &(timestamp));
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
		    fprintf(logFp, "\nStore: %s", timestr);
                    printf("\nStore: %s", timestr);
                    break;
                case MARK_MSG:
                    rns_send_mark();
                    clock_gettime(CLOCK_REALTIME, &(timestamp));
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
		    fprintf(logFp, "\nMark: %s", timestr);
                    printf("\nMark: %s", timestr);
                    break;
                case MAGNET_MSG:
                    rns_send_magnet();
                    clock_gettime(CLOCK_REALTIME, &(timestamp));
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
		    fprintf(logFp, "\nMagnet: %s", timestr);
                    printf("\nMagnet: %s", timestr);
                    break;
                case STIM_MSG:
                    rns_send_stim();
                    clock_gettime(CLOCK_REALTIME, &(timestamp));
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
		    fprintf(logFp, "\nStim: %s", timestr);
                    printf("\nStim: %s", timestr);
                    break;
                case EXTERNAL_MAGNET_MSG:
                    send_external_magnet();
                    clock_gettime(CLOCK_REALTIME, &(timestamp));
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
		    fprintf(logFp, "\nExternalMag: : %s", timestr);
                    printf("\nExternal magnet: %s", timestr);
                    break;
//
//
//
// To stop server press CTRL-C. The server automatically restarts after the client has been disconnected and is ready to receive another connection
//
//
//
/*                case RESTART_MSG:
                    serv->connected = false;
                    clock_gettime(CLOCK_REALTIME, &(timestamp));
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
                    printf("\n\nServer restart: %s\n\n", timestr);
                    break;
                case CLOSE_MSG:

                    clock_gettime(CLOCK_REALTIME, &(timestamp));
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
                    printf("\n\nServer closing: %s\n\n", timestr);
                    serverEnabled = false;
		    serv->connected = false;
                    break;
*/
		case 0:
                    serv->connected = false;
                    clock_gettime(CLOCK_REALTIME, &(timestamp));
                    timespec2str(timestr, sizeof(timestr), &timestamp);                    
		    fprintf(logFp, "\nStop: %s", timestr);
		    fclose(logFp);
		    logFp = NULL;
                    printf("\n\nServer restart: %s\n\n", timestr);
                    break;


            }
        }
    }
	printf("\nServer closed.\n");
	if(logFp != NULL)
	{
		fclose(logFp);
		logFp = NULL;
	}
	rns_close();
	return NULL;
}
