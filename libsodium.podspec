Pod::Spec.new do |s|
  s.name             = 'libsodium'
  s.version          = '1.0.3'        # 使用新版本号
  s.summary          = 'A modern crypto library with ObjC wrapper'
  s.description      = 'Libsodium binary framework plus HNSodiumCryptoBox helper'
  s.homepage         = 'https://github.com/baishilong/libsodium-apple'
  s.license          = 'ISC'
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :git => 'https://github.com/baishilong/libsodium-apple.git', :tag => s.version.to_s }

  # 二进制框架
  s.vendored_frameworks = 'Clibsodium.xcframework'

  # 源码包装类（HNSodiumCryptoBox）
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'

  # 告诉编译器去哪里找 sodium.h
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/Clibsodium.xcframework/ios-arm64/Clibsodium.framework/Headers" "${PODS_TARGET_SRCROOT}/Clibsodium.xcframework/ios-arm64_x86_64-simulator/Clibsodium.framework/Headers"'
  }

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  # 其他平台根据需要
end
