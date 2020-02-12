#include <stdio.h>
#include <time.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <bcm2835.h>


static int fd;

static int accurate_sleep(double sleep_time)
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

int rns_open(int rns_device, char* serial_port)
{
	fd = open(serial_port, O_RDWR | O_NOCTTY | O_NDELAY);

	if(fd == -1)
		printf("\n Error! in Opening tty port");
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
		printf("\n ERROR ! in setting attr");

	tcflush(fd, TCIOFLUSH);

}

int rns_close()
{
    close(fd);
}

int rns_send_store()
{
	unsigned char write_buffer[] = "r";
	int bytes_written = write(fd, write_buffer, 1);
	return bytes_written;
}

int rns_send_mark()
{
	unsigned char write_buffer[] = "t";
	int bytes_written = write(fd, write_buffer, 1);
	return bytes_written;
}

int rns_send_magnet()
{
	unsigned char write_buffer[] = "m";
	int bytes_written = write(fd, write_buffer, 1);
	return bytes_written;
}

int rns_send_stim()
{
	unsigned char write_buffer[] = "s";
	int bytes_written = write(fd, write_buffer, 1);
	return bytes_written;
}
