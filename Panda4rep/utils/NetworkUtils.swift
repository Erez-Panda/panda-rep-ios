//
//  NetworkUtils.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/24/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import Foundation
import SystemConfiguration

struct NetworkUtils {
    
    static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        /*
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        */
        return true //(isReachable && !needsConnection) ? true : false
    }
    
    static func checkConnection() -> Bool {
        if (!isConnectedToNetwork()){
            ViewUtils.showSimpleError("Cannot connect to server, Please check you internet connection")
            return false
        }
        return true
    }
}

