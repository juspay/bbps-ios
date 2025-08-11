Pod::Spec.new do |s|
    s.name         = "BBPSSDK"
    s.version      = "HYPER_SDK_VERSION"
    s.summary      = "Hyper visualization and payment processing."
    s.description  = <<-DESC
                    Create payment experiences for user to improve conversion and success rate.
                    DESC

    s.license      = { :type => "LGPL", :file => "LICENSE" }

    s.platform     = :ios, "12.0"

    s.source       = { :http => "https://public.releases.juspay.in/hyper-sdk/ios/tenant-wrappers/HYPER_SDK_VERSION/BBPSSDK.zip"}

    s.source_files = '**/*.{h, m}'
    s.resources    = ['Fuse.rb']

    # default dependency
    s.dependency 'HyperSDK', 'HYPER_SDK_VERSION'

    # optional dependencies need to be added based on the clientId which we get from the podspec URL
    s.dependency 'HyperUPI', 'HYPER_SDK_VERSION'
    s.dependency 'HyperQR', 'HYPER_SDK_VERSION'
    s.dependency 'HyperAPay', 'HYPER_SDK_VERSION'
    s.dependency 'HyperPayU', 'HYPER_SDK_VERSION'
    s.dependency 'HyperTrident', 'HYPER_SDK_VERSION'
    s.dependency 'HyperPayPal', 'HYPER_SDK_VERSION'
end
