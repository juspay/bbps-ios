require 'json'

tenantParams = {
  resource_url: "https://public.releases.juspay.in/hyper/bundles/in.juspay.merchants/%@client_id/ios/release/assets.zip",
  sandbox_resource_url: "https://public.releases.juspay.in/hyper/bundles/in.juspay.merchants/%@client_id/ios/release/assets.zip",
  versioned_resource_url: "https://public.releases.juspay.in/hyper-sdk/in/juspay/merchants/hyper.assets.%@client_id/%@asset_version/hyper.assets.%@client_id-%@asset_version.zip",
  merchant_config_json: "BBPSConfig.json",
  tenant_id: "bbps"
}

# Detect package manager and set appropriate path
fuse_path = if Dir.exist?("./Pods/HyperSDK")
  "./Pods/HyperSDK/Fuse.rb"
elsif ENV['BUILD_DIR'] && Dir.exist?("#{ENV['BUILD_DIR'].sub(/Build.*/, '')}SourcePackages/artifacts/hypersdk-ios/HyperSDK")
  "#{ENV['BUILD_DIR'].sub(/Build.*/, '')}SourcePackages/artifacts/hypersdk-ios/HyperSDK/Fuse.rb"
elsif Dir.exist?(File.join(__dir__, "../../hypersdk-ios/HyperSDK"))
  File.join(__dir__, "../../hypersdk-ios/HyperSDK/Fuse.rb")
else
  abort("Error: HyperSDK Fuse.rb not found. Please ensure HyperSDK is installed via CocoaPods or SPM.")
end

system("ruby", fuse_path, "true", "xcframework", JSON.generate(tenantParams))