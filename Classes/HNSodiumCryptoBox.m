#import "HNSodiumCryptoBox.h"
#import <sodium.h>
@implementation HNSodiumCryptoBox {
    NSData *_mySecretKey;
    NSData *_peerPublicKey;
    unsigned char _mySecretKeyBytes[crypto_box_SECRETKEYBYTES];
    unsigned char _peerPublicKeyBytes[crypto_box_PUBLICKEYBYTES];
    BOOL _keysValid;
}

#pragma mark - 公共类方法

+ (BOOL)initializeSodium {
    if (sodium_init() < 0) {
        NSLog(@"[SodiumCryptoBox] ❌ libsodium 初始化失败");
        return NO;
    }
    NSLog(@"[SodiumCryptoBox] ✅ libsodium 初始化成功");
    return YES;
}

+ (NSDictionary<NSString*,NSData*> *)generateKeyPair {
    unsigned char publicKey[crypto_box_PUBLICKEYBYTES];
    unsigned char secretKey[crypto_box_SECRETKEYBYTES];
    crypto_box_keypair(publicKey, secretKey);
    
    NSData *pubData = [NSData dataWithBytes:publicKey length:crypto_box_PUBLICKEYBYTES];
    NSData *secData = [NSData dataWithBytes:secretKey length:crypto_box_SECRETKEYBYTES];
    
    return @{
        @"publicKey" : pubData,
        @"secretKey" : secData
    };
}

+ (NSData *)randomNonce {
    unsigned char nonce[crypto_box_NONCEBYTES];
    randombytes_buf(nonce, sizeof(nonce));
    return [NSData dataWithBytes:nonce length:crypto_box_NONCEBYTES];
}

#pragma mark - 初始化

- (nullable instancetype)initWithMySecretKey:(NSData *)mySecretKey
                               peerPublicKey:(NSData *)peerPublicKey {
    self = [super init];
    if (self) {
        // 长度检查
        if (mySecretKey.length != crypto_box_SECRETKEYBYTES ||
            peerPublicKey.length != crypto_box_PUBLICKEYBYTES) {
            NSLog(@"[SodiumCryptoBox] ❌ 密钥长度错误: 私钥应为 %d 字节, 公钥应为 %d 字节",
                  crypto_box_SECRETKEYBYTES, crypto_box_PUBLICKEYBYTES);
            return nil;
        }
        
        // 保存原始 NSData 用于可能的后续导出（可选）
        _mySecretKey = [mySecretKey copy];
        _peerPublicKey = [peerPublicKey copy];
        
        // 复制到 C 数组
        memcpy(_mySecretKeyBytes, mySecretKey.bytes, crypto_box_SECRETKEYBYTES);
        memcpy(_peerPublicKeyBytes, peerPublicKey.bytes, crypto_box_PUBLICKEYBYTES);
        _keysValid = YES;
    }
    return self;
}

#pragma mark - 加密

- (NSDictionary<NSString*,NSData*> *)encryptMessage:(NSString *)plainText {
    if (!_keysValid) {
        NSLog(@"[SodiumCryptoBox] ❌ 加密失败: 密钥无效");
        return nil;
    }
    if (plainText.length == 0) {
        NSLog(@"[SodiumCryptoBox] ❌ 加密失败: 明文为空");
        return nil;
    }
    
    // 1. 准备明文数据
    const char *message = [plainText UTF8String];
    unsigned long long messageLen = strlen(message);
    if (messageLen == 0) {
        NSLog(@"[SodiumCryptoBox] ❌ 加密失败: 无法转换为 UTF-8 字符串");
        return nil;
    }
    
    // 2. 密文缓冲区大小 = 明文长度 + MAC 长度
    unsigned long long ciphertextLen = messageLen + crypto_box_MACBYTES;
    unsigned char *ciphertext = malloc(ciphertextLen);
    if (!ciphertext) {
        NSLog(@"[SodiumCryptoBox] ❌ 内存分配失败");
        return nil;
    }
    
    // 3. 生成随机 Nonce
    unsigned char nonce[crypto_box_NONCEBYTES];
    randombytes_buf(nonce, sizeof(nonce));
    
    // 4. 加密
    int ret = crypto_box_easy(ciphertext,
                              (const unsigned char *)message,
                              messageLen,
                              nonce,
                              _peerPublicKeyBytes,
                              _mySecretKeyBytes);
    
    if (ret != 0) {
        NSLog(@"[SodiumCryptoBox] ❌ 加密失败, 错误码: %d", ret);
        free(ciphertext);
        return nil;
    }
    
    // 5. 封装结果
    NSData *ciphertextData = [NSData dataWithBytesNoCopy:ciphertext
                                                   length:ciphertextLen
                                             freeWhenDone:YES];
    NSData *nonceData = [NSData dataWithBytes:nonce length:crypto_box_NONCEBYTES];
    
    return @{
        @"ciphertext" : ciphertextData,
        @"nonce"      : nonceData
    };
}

#pragma mark - 解密

- (nullable NSString *)decryptMessage:(NSData *)ciphertext withNonce:(NSData *)nonce {
    if (!_keysValid) {
        NSLog(@"[SodiumCryptoBox] ❌ 解密失败: 密钥无效");
        return nil;
    }
    if (ciphertext.length < crypto_box_MACBYTES) {
        NSLog(@"[SodiumCryptoBox] ❌ 解密失败: 密文太短");
        return nil;
    }
    if (nonce.length != crypto_box_NONCEBYTES) {
        NSLog(@"[SodiumCryptoBox] ❌ 解密失败: Nonce 长度错误 (应为 %d 字节)", crypto_box_NONCEBYTES);
        return nil;
    }
    
    unsigned long long ciphertextLen = (unsigned long long)ciphertext.length;
    unsigned long long messageLen = ciphertextLen - crypto_box_MACBYTES;
    unsigned char *message = malloc(messageLen + 1);
    if (!message) {
        NSLog(@"[SodiumCryptoBox] ❌ 内存分配失败");
        return nil;
    }
    
    int ret = crypto_box_open_easy(message,
                                   ciphertext.bytes,
                                   ciphertextLen,
                                   nonce.bytes,
                                   _peerPublicKeyBytes,
                                   _mySecretKeyBytes);
    
    if (ret != 0) {
        // 注意：此处不打印详细错误信息，避免泄露信息
        NSLog(@"[SodiumCryptoBox] ❌ 解密或验证失败 (可能被篡改或密钥不匹配)");
        free(message);
        return nil;
    }
    
    // 确保字符串以 null 结尾
    message[messageLen] = '\0';
    NSString *decryptedText = [NSString stringWithUTF8String:(const char *)message];
    free(message);
    
    if (!decryptedText) {
        NSLog(@"[SodiumCryptoBox] ❌ 解密后的数据不是有效的 UTF-8 字符串");
    }
    return decryptedText;
}

@end
