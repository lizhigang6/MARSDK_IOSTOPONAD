Pod::Spec.new do |s|

  s.name             = 'MARSDK_IOSTOPONAD'
  s.version          = '2.1.3'
  s.summary          = '广告渠道配合marsdk 使用'
  s.description  = <<-DESC
火星人打包工具sdk 
                   DESC
s.homepage     = "https://github.com/lizhigang6/MARSDK_IOSTOPONAD.git"# 你git库的地址首页,可以在开元中国创建你的库,不需要使用什么初始化方法,不要勾选 readme
s.license          = { :type => 'MIT', :file => 'LICENSE' } #这里不需要改变,使用默认,文件指向的文件名与工程中文件名要一致。
s.author           = { '名字' => 'lizhigang6@163.com' } #作者信息：账户名，账户邮箱地址
s.source           = { :git => 'https://github.com/lizhigang6/MARSDK_IOSTOPONAD.git', :tag => s.version.to_s } # 这里输入邮箱如果你在开元中国申请的 git 账号,那么把你在开元中国创建的项目的 https 网址输入到这里,
s.platform     = :ios
s.platform     = :ios, "10.0" #iOS 支持的最低级别,这里最低9.0
s.vendored_libraries =  'MARSDK_IOSTOPONAD/SDK/libMARSDK_IOSTOPONAD.a'
s.vendored_frameworks  = 'MARSDK_IOSTOPONAD/Classes/*.framework' 
s.resource_bundles = {
     'toponBundle' => ['MARSDK_IOSTOPONAD/Assets/*']
 }
#s.frameworks = "AVFoundation","AdSupport","CoreLocation","CoreMedia","CoreMotion","CoreTelephony","JavaScriptCore","MobileCoreServices","SafariServices","StoreKit","SystemConfiguration"
#s.ios.library = "z","xml2","sqlite3","resolv.9","c++","bz2","c++abi"  
# s.dependency 'AnyThinkiOS','~> 5.9.61'
s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64'}
end