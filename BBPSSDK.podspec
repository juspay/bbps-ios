Pod::Spec.new do |s|
  s.name             = 'BBPSSDK'
  s.version          = File.read(File.join(__dir__, 'VERSION')).strip
  s.summary          = 'BBPS SDK for bill payments on iOS'
  s.description      = <<-DESC
                       BBPS SDK enables bill payment experiences on iOS.
                       Integrates with HyperSDK for payment processing.
                       DESC

  s.homepage         = 'https://github.com/juspay/bbps-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Juspay' => 'support@juspay.in' }
  s.source           = { :git => 'https://github.com/juspay/bbps-ios.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '12.0'

  s.source_files     = 'Sources/BBPSSDK/**/*.{h,m}'
  s.public_header_files = 'Sources/BBPSSDK/**/*.h'

  s.resources        = ['Sources/BBPSSDK/Fuse.rb', 'Sources/BBPSSDK/tenants_config.json']
  s.preserve_paths   = ['Sources/BBPSSDK/Fuse.rb']

  s.dependency 'HyperSDK', '2.2.7'

  s.prepare_command = <<-CMD
    echo "BBPSSDK #{s.version} installed. Run Fuse.rb during build to download assets."
  CMD
end
