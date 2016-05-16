//
//  Beacon.swift
//  ProxReporter
//
//  Created by Cole Richards on 5/14/16.
//  Copyright © 2016 ROXIMITY. All rights reserved.
//

import CoreFoundation

class Beacon: NSObject {
    var name:String
    var identifier:String
    var proximity: Int32!
    
    
    init(name:String, identifier:String, proximity:Int32?){
        self.name = name
        self.identifier = identifier
        super.init()
        updateProximity(proximity)
    }
    
    func updateProximity(proximity:Int32?){
        if proximity != nil {self.proximity = proximity!}
        else {self.proximity = 0}
    }
}
