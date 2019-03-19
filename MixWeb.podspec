Pod::Spec.new do |s|
    s.name = 'MixWeb'
    s.version = '0.9.0'
    s.summary = 'UIWebView for micro program'
    s.authors = { 'Eric Long' => 'longminxiang@163.com' }
    s.license = 'MIT'
    s.homepage = "https://github.com/longminxiang/MixWeb"
    s.source  = { :git => "https://github.com/longminxiang/MixWeb.git", :tag => "v" + s.version.to_s }
    s.requires_arc = true
    s.ios.deployment_target = '8.0'

    s.default_subspec = 'Core'

    s.subspec 'Core' do |c|
        c.source_files = 'MixWeb/**/*.{h,m}'
        c.exclude_files = 'MixWeb/MWVImageModule/*.{h,m}'
        c.dependency 'MixExtention', '~> 1.0'
        c.dependency 'SDWebImage/Core', '~> 4.4.0'
        c.dependency 'WebViewJavascriptBridge', '~> 6.0.3'
        c.dependency 'MBProgressHUD', '0.9.2'
        c.dependency 'MixDevice', '~> 1.0.4'
        c.dependency 'MixCache_Objc', '~> 1.0.3'
    end

    s.subspec 'Image' do |c|
        c.source_files = 'MixWeb/MWVImageModule/**/*.{h,m}'
        c.resource_bundles = {'TTAD' => 'Apps/AD/View/*.{xib,png}'}
        c.dependency 'TZImagePickerController', '~> 3.2.0'
    end

end
