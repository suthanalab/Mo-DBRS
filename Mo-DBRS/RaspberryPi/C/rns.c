#include <stdio.h>
#include <time.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <bcm2835.h>
#define  BILLION 1000000000.0


#define MAGNET_PIN RPI_BPLUS_GPIO_J8_40
#define RECORD_PIN RPI_BPLUS_GPIO_J8_38


int better_sleep(double sleep_time)
{
	struct timespec tv;
	tv.tv_sec = (time_t) sleep_time;
	tv.tv_nsec = (long)((sleep_time - tv.tv_sec) * 1e+9);

	while(1)
	{
		int rval = nanosleep(&tv, &tv);
		if(rval == 0)
			return 0;
		else if(errno == EINTR)
			continue;
		else
			return rval;
	}
	return 0;
}

int fd;

int rns_open(int rns_device, char* dev_port)
{

	fd = open(dev_port, O_RDWR | O_NOCTTY | O_NDELAY);

	if(fd == -1)
	{
		printf("\n\nSerial port error. Make sure that the Programmer Accessory is connected\n\n");
		return -1;
	}
	else
		printf("\n tty Opened Successfully");

	struct termios SerialPortSettings;
	fcntl(fd, F_SETFL, FNDELAY);

	tcgetattr(fd, &SerialPortSettings);

	tcflush(fd, TCIOFLUSH);

	if(rns_device == 300)
	{
		cfsetispeed(&SerialPortSettings, B9600);
		cfsetospeed(&SerialPortSettings, B9600);
	}
	else if(rns_device == 320)
	{
		cfsetispeed(&SerialPortSettings, B57600);
		cfsetospeed(&SerialPortSettings, B57600);
	}

	SerialPortSettings.c_cflag &= ~PARENB;
	SerialPortSettings.c_cflag &= ~CSTOPB;
	SerialPortSettings.c_cflag &= ~CSIZE;
	SerialPortSettings.c_cflag |= CS8;


	SerialPortSettings.c_cflag &= ~CRTSCTS;
	SerialPortSettings.c_cflag |= CREAD | CLOCAL;


	SerialPortSettings.c_iflag &= ~(IXON | IXOFF | IXANY);
	SerialPortSettings.c_iflag &= ~(ICANON | ECHO | ECHOE | ISIG);

	SerialPortSettings.c_oflag &= ~OPOST;

	if((tcsetattr(fd, TCSANOW, &SerialPortSettings)) != 0)
	{
		printf("\n ERROR ! in setting attr");
		return -1;
	}


	tcflush(fd, TCIOFLUSH);

	printf("\nEstablishing the Programmer Accessory connection...");
	sleep(10);

	printf("\nProgrammer Accessory is ready.");
	return 0;

}

int rns_close()
{
	if(fd != -1)
		close(fd);
	return 0;
}

int rns_send_store()
{
	int retCode = -1;
	if(fd != - 1)
	{
		unsigned char write_buffer[] = "r";
		retCode = write(fd, write_buffer, 1);
	}
	else
	{
		printf("\nThe Programmer Accessory is not connected.");
	}
	return retCode;
}
int rns_send_stim()
{
	int retCode = -1;
	if(fd != - 1)
	{
		unsigned char write_buffer[] = "s";
		retCode = write(fd, write_buffer, 1);
	}
	else
	{
		printf("\nThe Programmer Accessory is not connected.");
	}
	return retCode;
}
int rns_send_mark()
{
	int retCode = -1;
	if(fd != - 1)
	{
		unsigned char write_buffer[] = "t";
		retCode = write(fd, write_buffer, 1);
	}
	else
	{
		printf("\nThe Programmer Accessory is not connected.");
	}
	return retCode;
}
int rns_send_magnet()
{
	int retCode = -1;
	if(fd != - 1)
	{
		unsigned char write_buffer[] = "m";
		retCode = write(fd, write_buffer, 1);
	}
	else
	{
		printf("\nThe Programmer Accessory is not connected.");
	}
	return retCode;
}
