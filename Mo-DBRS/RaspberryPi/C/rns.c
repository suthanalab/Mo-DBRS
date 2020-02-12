#include <stdio.h>
#include <time.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>
#include <bcm2835.h>
#include <Python.h>
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


int send_ssr(int fd)
{
	unsigned char write_buffer[] = "r";
	int bytes_written = write(fd, write_buffer, 1);
	return bytes_written;
}
int send_stim(int fd)
{
	unsigned char write_buffer[] = "s";
	int bytes_written = write(fd, write_buffer, 1);
	return bytes_written;
}
int send_mark(int fd)
{
	unsigned char write_buffer[] = "t";
	int bytes_written = write(fd, write_buffer, 1);
	return bytes_written;
}
int send_magnet(int fd)
{
	unsigned char write_buffer[] = "m";
	int bytes_written = write(fd, write_buffer, 1);
	return bytes_written;
}


int main(void)
{

	if(!bcm2835_init())
		printf("BCM Init failed!\n");
	bcm2835_gpio_fsel(MAGNET_PIN, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(RECORD_PIN, BCM2835_GPIO_FSEL_OUTP);
	

	struct timespec start, end;
	clock_gettime(CLOCK_REALTIME, &start);
	bcm2835_gpio_write(MAGNET_PIN, HIGH);
	clock_gettime(CLOCK_REALTIME, &end);
	double time_spent = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / BILLION;
	printf("\n%f\n", time_spent);


	clock_gettime(CLOCK_REALTIME, &start);
	bcm2835_gpio_write(MAGNET_PIN, LOW);
	clock_gettime(CLOCK_REALTIME, &end);
	time_spent = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / BILLION;
	printf("\n%f\n", time_spent);



	int n = 50;
	while(n>0)
	{

		bcm2835_gpio_write(RECORD_PIN, HIGH);
		better_sleep(1.0);
		bcm2835_gpio_write(RECORD_PIN, LOW);
		better_sleep(1.0);
		n--;
	}

	return 0;
/*
	int fd;

	fd = open("/dev/ttyACM0", O_RDWR | O_NOCTTY | O_NDELAY);

	if(fd == -1)
		printf("\n Error! in Opening tty port");
	else
		printf("\n tty Opened Successfully");

	struct termios SerialPortSettings;
	fcntl(fd, F_SETFL, FNDELAY);

	tcgetattr(fd, &SerialPortSettings);

	tcflush(fd, TCIOFLUSH);

	cfsetispeed(&SerialPortSettings, B9600);
	cfsetospeed(&SerialPortSettings, B9600);

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
	else
		printf("\n BaudRate = 9600 \n StopBits = 1 \n Parity = none");


	tcflush(fd, TCIOFLUSH);

	sleep(10);



	struct timespec start, end;
	clock_gettime(CLOCK_REALTIME, &start);
	send_mark(fd);
	clock_gettime(CLOCK_REALTIME, &end);
	double time_spent = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / BILLION;
	printf("\n%f\n", time_spent);
	
	better_sleep(5.0);

	int n = 5;
	int i = 0;
	struct timespec mark_timestamps[n];
	while(i<n)
	{
		send_mark(fd);
		clock_gettime(CLOCK_REALTIME, &mark_timestamps[i++]);
		better_sleep(15.0);	
	}

	better_sleep(10.0);
	send_ssr(fd);


	for(i = 0; i < n; i++)
	{
		struct tm* mark_tm;
		mark_tm = localtime(&mark_timestamps[i].tv_sec);
		int mark_tm_sec = mark_tm->tm_min*60 + mark_tm->tm_sec;
		printf("%d.%09ld\n", mark_tm_sec, mark_timestamps[i].tv_nsec);
	}


	close(fd);
	
*/
}
