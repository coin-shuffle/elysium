#include <stdint.h>

const char* rust_encrypt(const char* _msg, const char* _nonce, const char* _pem);
const char* rust_decrypt(const char* _msg, const char* _pem);
const char* rust_sign(const char* _msg, const char* _key);
const char* rust_tx_sign(const char* _msg, const char* _key);
void rust_free(char *);
