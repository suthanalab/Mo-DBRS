# Raspberry C Server (incomplete - coming soon)

# BCM 2835 Driver for RP GPIOs

  Download from: http://www.airspayce.com/mikem/bcm2835/bcm2835-1.60.tar.gz
  ```console
  $ tar zxvf bcm2835-1.xx.tar.gz
  $ cd bcm2835-1.xx
  $ ./configure
  $ make
  $ sudo make check
  $ sudo make install
  ```
  
# Compilation & Run
  
  - Make sure to add BCM header file to the library path by typing '-L..' or copy compiled BCM library to the same folder
  
   ```console
  $ gcc -Wall rns.c rns_server.c main.c -o main -lbcm2835
  $ sudo ./main
  ```
