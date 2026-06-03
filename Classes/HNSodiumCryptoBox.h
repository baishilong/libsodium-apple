#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 基于 libsodium crypto_box 的公钥加密工具（X25519 + XSalsa20 + Poly1305）
@interface HNSodiumCryptoBox : NSObject

/// 初始化 libsodium（应在应用启动时调用一次）
/// @return 成功返回 YES，失败返回 NO
+ (BOOL)initializeSodium;

/// 生成一个新的密钥对（公钥 + 私钥）
/// @return 字典包含 @"publicKey" (NSData) 和 @"secretKey" (NSData)
+ (NSDictionary<NSString*, NSData*> *)generateKeyPair;

/// 生成一个随机的 Nonce（24 字节）
+ (NSData *)randomNonce;

/// 使用自己的私钥和对方的公钥初始化
/// @param mySecretKey   自己的私钥（NSData）
/// @param peerPublicKey 对方的公钥（NSData）
/// @return 实例，如果密钥长度无效则返回 nil
- (nullable instancetype)initWithMySecretKey:(NSData *)mySecretKey
                               peerPublicKey:(NSData *)peerPublicKey;

/// 加密一段明文消息（内部自动生成随机 Nonce）
/// @param plainText 要加密的字符串
/// @return 字典包含 @"ciphertext" (NSData) 和 @"nonce" (NSData)，失败返回 nil
- (nullable NSDictionary<NSString*, NSData*> *)encryptMessage:(NSString *)plainText;

/// 解密消息
/// @param ciphertext 密文数据（包含认证标签）
/// @param nonce      加密时使用的 Nonce
/// @return 解密后的明文字符串，失败（认证失败或数据损坏）返回 nil
- (nullable NSString *)decryptMessage:(NSData *)ciphertext withNonce:(NSData *)nonce;

@end

NS_ASSUME_NONNULL_END
