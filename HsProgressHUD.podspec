Pod::Spec.new do |spec|
  spec.name         = 'HsProgressHUD'
  spec.version      = '1.1.8'
  spec.summary      = 'one can dismiss ProgressHUD with message 、warn、error、success、loading，and warn and error never dismiss'
  spec.homepage     = 'https://github.com/wangjindong/HsProgressHUD'
  spec.license      = 'MIT'
  #spec.license = { :type => 'MIT', :file => 'FILE_LICENSE' }
  spec.author       = { 'wangjindong' => '419591321@qq.com' }
  #spec.social_media_url   = 'http://twitter.com/hundsun'
  spec.platform = :ios,'5.0'
  spec.source  = {:git=>'https://github.com/wangjindong/HsProgressHUD.git',:tag=>spec.version}
  spec.source_files = 'HsProgressHUD/HsProgressHUD/*'
  #spec.exclude_files = 'HsProgressHUD/**/*'
  spec.resource = 'HsProgressHUD/HsProgressHUD/*.bundle'

  spec.requires_arc = true
  #spec.ios.deployment_target = '7.0'
  #spec.public_header_files = 'HsProgressHUD/*.h'
  spec.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'

end