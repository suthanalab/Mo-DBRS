#include "rns_server.h"
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int main()
{

    Parameters param;

    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;

    fp = fopen("./rns.conf", "r");
    if (fp == NULL)
    {
	    printf("Error. Configuration file does not exist.");
	    return -1;
    }

    	char sep[] = " \n";
	char* name;
	char* value;

	printf("\n\nLoaded Parameters:\n\n");

    while ((read = getline(&line, &len, fp)) != -1) {
	if(line[0] != '#')
	{
		name = strtok( line, sep );
		if(!strcmp(name, "IP"))
		{
			value = strtok( NULL, sep );
			printf("\tIP:\t%s\n", value );
			param.ip_address = (char*)malloc(sizeof(char) * (strlen(value) + 1));
			strcpy(param.ip_address, value);
		}
		else if(!strcmp(name, "PORT"))
		{
			value = strtok( NULL, sep );
			printf( "\tPORT:\t%s\n", value );
			param.port = atoi(value);
		}
		else if(!strcmp(name, "SERIAL"))
		{
			value = strtok( NULL, sep );
			printf( "\tSERIAL:\t%s\n", value);
			param.dev_port = (char*)malloc(sizeof(char) * (strlen(value) + 1));
			strcpy(param.dev_port, value);
		}
		else if(!strcmp(name, "DEVICE"))
		{
			value = strtok( NULL, sep );
			printf( "\tDEVICE:\t%s\n", value );
			param.rns_device = atoi(value);
		}

	}
    }

    fclose(fp);
    if (line)
        free(line);


    server_open(param);
    free(param.ip_address);
    free(param.dev_port);

    server_join();
    return 0;
}
