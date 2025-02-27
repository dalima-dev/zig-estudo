#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Base64
{
    const char *table;
    char (*char_at)(const struct Base64 *, int);
    int (*char_index)(const struct Base64 *, char);
} Base64;

const char BASE64_TABLE[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

char base64_char_at(const Base64 *b64, int index)
{
    return b64->table[index];
}

int base64_char_index(const Base64 *b64, char c)
{
    if (c == '=')
        return 64;
    for (int i = 0; i < 64; i++)
    {
        if (b64->table[i] == c)
            return i;
    }
    return -1;
}

void base64_init(Base64 *b64)
{
    b64->table = BASE64_TABLE;
    b64->char_at = base64_char_at;
    b64->char_index = base64_char_index;
}

size_t calc_encode_length(size_t input_len)
{
    return ((input_len + 2) / 3) * 4;
}

size_t calc_decode_length(const char *input)
{
    size_t len = strlen(input);
    size_t padding = (input[len - 1] == '=') + (input[len - 2] == '=');
    return (len / 4) * 3 - padding;
}

char *base64_encode(const Base64 *b64, const char *input)
{
    size_t input_len = strlen(input);
    size_t output_len = calc_encode_length(input_len);
    char *output = malloc(output_len + 1);
    if (!output)
        return NULL;

    int i, j;
    unsigned char tmp[3];
    for (i = 0, j = 0; i < input_len;)
    {
        memset(tmp, 0, 3);
        for (int k = 0; k < 3 && i < input_len; k++, i++)
        {
            tmp[k] = input[i];
        }
        output[j++] = b64->char_at(b64, tmp[0] >> 2);
        output[j++] = b64->char_at(b64, ((tmp[0] & 0x03) << 4) | (tmp[1] >> 4));
        output[j++] = (i > input_len + 1) ? '=' : b64->char_at(b64, ((tmp[1] & 0x0F) << 2) | (tmp[2] >> 6));
        output[j++] = (i > input_len) ? '=' : b64->char_at(b64, tmp[2] & 0x3F);
    }
    output[j] = '\0';
    return output;
}

char *base64_decode(const Base64 *b64, const char *input)
{
    size_t input_len = strlen(input);
    size_t output_len = calc_decode_length(input);
    char *output = malloc(output_len + 1);
    if (!output)
        return NULL;

    int i, j;
    unsigned char tmp[4];
    for (i = 0, j = 0; i < input_len;)
    {
        memset(tmp, 0, 4);
        for (int k = 0; k < 4 && i < input_len; k++, i++)
        {
            tmp[k] = b64->char_index(b64, input[i]);
        }
        output[j++] = (tmp[0] << 2) | (tmp[1] >> 4);
        if (tmp[2] != 64)
            output[j++] = (tmp[1] << 4) | (tmp[2] >> 2);
        if (tmp[3] != 64)
            output[j++] = (tmp[2] << 6) | tmp[3];
    }
    output[j] = '\0';
    return output;
}

int main()
{
    Base64 base64;
    base64_init(&base64);

    const char *text = "Testing some more shit";
    const char *encoded_text = "VGVzdGluZyBzb21lIG1vcmUgc2hpdA==";

    char *encoded = base64_encode(&base64, text);
    char *decoded = base64_decode(&base64, encoded_text);

    printf("Encoded text: %s\n", encoded);
    printf("Decoded text: %s\n", decoded);

    free(encoded);
    free(decoded);
    return 0;
}
