//
//  BeaconObserver.swift
//  ProxReporter
//
//  Created by Cole Richards on 5/14/16.
//  Copyright © 2016 ROXIMITY. All rights reserved.
//

import CoreFoundation

let kName = "beacon_name"
let kProx = "proximity_value"
let kId = "beacon_id"

class BeaconObserver: NSObject, ROXBeaconRangeUpdateDelegate, SignalIndicator {

    var signalDelegate:SignalResponderDelegate
    var beaconsByName = [String:Beacon]()
    
    var bandIds = [String]()
    
    required init(signalDelegate: SignalResponderDelegate){
        self.signalDelegate = signalDelegate
        super.init()
        ROXIMITYEngine.setBeaconRangeDelegate(self, withUpdateInterval: kROXBeaconRangeUpdatesFastest)
    }
    
    
    func didUpdateBeaconRanges(rangedBeacons:[AnyObject]){
//        print(rangedBeacons)
        
        for beaconDict in rangedBeacons{
            let name = String(beaconDict.objectForKey(kName)!)
            let prx = beaconDict.objectForKey(kProx)?.intValue
            let id = String(beaconDict.objectForKey(kId))
            
            if let beacon = beaconsByName[name] {
                beacon.updateProximity(prx)
            }else{
                beaconsByName[name] = Beacon.init(name: name, identifier: id, proximity: prx)
            }
            
            if(bandIds.contains(name)){
                signalDelegate.didRecieveSignalUpdateWithIdentifer(name, andRSSI: Int(prx!))
            }
            
        }
    
        updateSignalResponder();
    }
    
    
    func resetBandMembers(identifiers:[String]){
        self.bandIds = identifiers
    }
    
    private func updateSignalResponder(){
        signalDelegate.updateRangedSignals(beaconsByName)
    }
}
