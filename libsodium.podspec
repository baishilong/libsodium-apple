Pod::Spec.new do |s|
  s.name             = 'libsodium'
  s.version          = '1.0.4'   # 升级版本
  s.summary          = 'A modern crypto library with ObjC wrapper'
  s.homepage         = 'https://github.com/baishilong/libsodium-apple'
  s.license          = 'ISC'
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :git => 'https://github.com/baishilong/libsodium-apple.git', :tag => s.version.to_s }

  # 二进制框架
  s.vendored_frameworks = 'Clibsodium.xcframework'

  # 源码包装类
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'

  # 关键设置：强制生成 framework 并允许非模块化头文件
  s.static_framework = true

  # 告诉编译器去哪里找 sodium.h
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/Clibsodium.xcframework/ios-arm64/Clibsodium.framework/Headers"',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'DEFINES_MODULE' => 'YES'
  }

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
end
