//
//  SignalSelectorDisplay.swift
//  bcnsonar
//
//  Created by Cole Richards on 5/13/16.
//  Copyright © 2016 ROXIMITY. All rights reserved.
//

import Foundation

protocol SignalSelectorDisplay {
    func didReceivedNewSignalsToDisplay(signals:[Beacon])
}
