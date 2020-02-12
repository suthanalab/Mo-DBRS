#ifndef RNS_H__
#define RNS_H__

int rns_open(int, char*);
int rns_close();
int rns_send_store();
int rns_send_mark();
int rns_send_magnet();
int rns_send_stim();

#endif /* RNS_H__*/
