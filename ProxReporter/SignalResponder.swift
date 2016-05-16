//
//  SignalRssiResponder.swift
//  bcnsonar
//
//  Created by Cole Richards on 5/5/16.
//  Copyright © 2016 ROXIMITY. All rights reserved.
//

import Foundation


protocol SignalResponderDelegate{
    func didRecieveSignalUpdateWithIdentifer(identifier: String, andRSSI rssi:Int)
    func updateRangedSignals(signalsByRssi: [String:Beacon])
}