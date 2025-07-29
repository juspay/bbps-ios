//
//  BBPSSDKDependencies.swift
//

import Foundation
import HyperSDK

@objc public class BBPSSDKDependencies: NSObject {
    
    @objc public static let shared = BBPSSDKDependencies()
    
    private override init() {
        super.init()
    }
    
    @objc public func initializeSDK() {
        // Initialize any required dependencies for BBPS SDK
    }
}