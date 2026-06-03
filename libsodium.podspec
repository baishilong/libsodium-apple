Pod::Spec.new do |s|
  s.name             = 'libsodium'
  s.version          = '1.0.0' 
  s.summary          = 'A modern and easy-to-use crypto library.'
  s.description      = 'Libsodium is a portable, cross-compilable crypto library.'
  s.homepage         = 'https://github.com/jedisct1/libsodium'
  s.license          = 'ISC'
  s.author           = { 'baishilong' => '790696023@qq.com.com' }
  s.source           = { :git => 'https://github.com/baishilong/libsodium-apple.git', :tag => s.version.to_s }

  s.vendored_frameworks = 'Clibsodium.xcframework'
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'  
s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
 # s.tvos.deployment_target = '12.0'
 # s.watchos.deployment_target = '4.0'
 # s.visionos.deployment_target = '1.0'

   s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/Clibsodium.xcframework/ios-arm64/Clibsodium.framework/Headers" "${PODS_TARGET_SRCROOT}/Clibsodium.xcframework/ios-arm64_x86_64-simulator/Clibsodium.framework/Headers"',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }

end
