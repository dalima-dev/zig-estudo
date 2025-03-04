#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define BUFFER_SIZE 1000

// Socket structure
typedef struct
{
    struct sockaddr_in address;
    int socket_fd;
} Socket;

Socket init_socket()
{
    Socket sock;
    sock.socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (sock.socket_fd == -1)
    {
        perror("Failed to create socket");
        exit(EXIT_FAILURE);
    }

    sock.address.sin_family = AF_INET;
    sock.address.sin_port = htons(3000);
    sock.address.sin_addr.s_addr = inet_addr("127.0.0.1");

    if (bind(sock.socket_fd, (struct sockaddr *)&sock.address, sizeof(sock.address)) < 0)
    {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    if (listen(sock.socket_fd, 3) < 0)
    {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }

    return sock;
}

// Request structure
typedef enum
{
    GET
} Method;

typedef struct
{
    Method method;
    char uri[256];
    char version[16];
} Request;

Method parse_method(const char *text)
{
    if (strcmp(text, "GET") == 0)
    {
        return GET;
    }
    fprintf(stderr, "Unsupported method: %s\n", text);
    exit(EXIT_FAILURE);
}

Request parse_request(char *buffer)
{
    char method_str[8], uri[256], version[16];
    sscanf(buffer, "%s %s %s", method_str, uri, version);

    Request req;
    req.method = parse_method(method_str);
    strcpy(req.uri, uri);
    strcpy(req.version, version);

    return req;
}

void read_request(int client_sock, char *buffer)
{
    recv(client_sock, buffer, BUFFER_SIZE, 0);
}

void send_200(int client_sock)
{
    const char *message = "HTTP/1.1 200 OK\nContent-Length: 48\nContent-Type: text/html\nConnection: Closed\n\n<html><body><h1>Hello, C!</h1></body></html>";
    send(client_sock, message, strlen(message), 0);
}

void send_404(int client_sock)
{
    const char *message = "HTTP/1.1 404 Not Found\nContent-Length: 50\nContent-Type: text/html\nConnection: Closed\n\n<html><body><h1>File not found!</h1></body></html>";
    send(client_sock, message, strlen(message), 0);
}

void initialize_buffer(char *buffer)
{
    memset(buffer, 0, BUFFER_SIZE);
}

int main()
{
    Socket server = init_socket();
    printf("Server Addr: 127.0.0.1:3000\n");

    struct sockaddr_in client_addr;
    socklen_t client_len = sizeof(client_addr);
    int client_sock = accept(server.socket_fd, (struct sockaddr *)&client_addr, &client_len);
    if (client_sock < 0)
    {
        perror("Accept failed");
        exit(EXIT_FAILURE);
    }

    char buffer[BUFFER_SIZE];
    initialize_buffer(buffer);
    read_request(client_sock, buffer);
    Request request = parse_request(buffer);

    if (request.method == GET)
    {
        if (strcmp(request.uri, "/") == 0)
        {
            send_200(client_sock);
        }
        else
        {
            send_404(client_sock);
        }
    }

    printf("{ method = GET, uri = %s, version = %s }\n", request.uri, request.version);

    close(client_sock);
    close(server.socket_fd);
    return 0;
}
