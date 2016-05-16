//
//  ViewController.swift
//  ProxReporter
//
//  Created by Cole Richards on 5/13/16.
//  Copyright © 2016 ROXIMITY. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, SignalSelectorDisplay, UITableViewDelegate, UITableViewDataSource{
    
    
    var tonePlayer: BLETonePlayer!
    var toneTracker = [String:Int]()
    var availSignals = [Beacon]()
    var toneSignals = [Beacon]()
    @IBOutlet weak var signalTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tonePlayer = BLETonePlayer.init(hostView: self)
        self.signalTable.registerClass(BLESignalTableCellTableViewCell.self, forCellReuseIdentifier: "BLESignalCell")
        self.signalTable.registerNib(UINib(nibName: "BLESignalTableCellTableViewCell", bundle: nil), forCellReuseIdentifier: "BLESignalCell")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didReceivedNewSignalsToDisplay(signals:[Beacon]){
        //split into tone signals and available signals
        let toneArray = [String](toneTracker.keys)
        toneSignals = signals.filter({toneArray.contains($0.name)})
        availSignals = signals.filter({!toneArray.contains($0.name)})
        self.signalTable.reloadData()
        
    }
    
    
    
    //TABLE VIEW METHODS
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch section {
        case 0:
            return toneSignals.count
        case 1:
            return availSignals.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerText = ""
        var height:CGFloat = 0
        
        switch section {
        case 0:
            headerText = "Playing Tone"
            if (toneSignals.count > 0){height = 20}
        case 1:
            headerText = "Silent"
            if (availSignals.count > 0){height = 20}
        default:
            break;
        }
        
        let headerFrame = CGRectMake(0, 0, tableView.frame.size.width, height)
        let headerView = UIView.init(frame: headerFrame)
        let headerLabel = UILabel.init(frame: headerFrame)
        
        headerLabel.text = headerText
        headerView.addSubview(headerLabel)
        return headerView;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var signals = [Beacon]()
        
        switch indexPath.section {
        case 0:
            signals = toneSignals
        case 1:
            signals = availSignals
        default:
            break;
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BLESignalCell", forIndexPath: indexPath) as! BLESignalTableCellTableViewCell
        let signal = signals[indexPath.row]
        
        cell.identifierLabel?.text = signal.name
        cell.signalStrengthLabel?.text =  String(signal.proximity)
        if let toneNumber = toneTracker[signal.name]{
            
            cell.toneLabel.text = String(toneNumber)
            if (toneNumber == 0){
                cell.toneLabel.text = ""
            }
        }else{
            cell.toneLabel.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var signals = [Beacon]()
        
        switch indexPath.section {
        case 0:
            signals = toneSignals
        case 1:
            signals = availSignals
        default:
            break;
        }
        
        let signal = signals[indexPath.row]
        
        var taps = toneTracker[signal.name] ?? 0
        if let tone = self.tonePlayer.getToneAtIndex(taps){
            taps += 1
            tonePlayer.createAudioPlayerWithIdentifier(signal.name, andAudioFileURL: tone)
        }else{
            taps = 0
            tonePlayer.removeToneForIdentifier(signal.name)
        }
        toneTracker[signal.name] = taps
    }
}

