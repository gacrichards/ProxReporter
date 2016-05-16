//
//  BLETonePlayer.swift
//  bcnsonar
//
//  Created by Cole Richards on 5/13/16.
//  Copyright © 2016 ROXIMITY. All rights reserved.
//

import Foundation
import AVFoundation

infix operator ^^ { }
func ^^ (radix: Float, power: Float) -> Float {
    return Float(pow(Double(radix), Double(power)))
}

class BLETonePlayer: NSObject, SignalResponderDelegate {

    
    private let maxVolume: Float = 1.0
    private let minVolume: Float = 0.01
    var playerTimers = [String: NSTimer]()
    private var hostView: SignalSelectorDisplay
    private var scanner: BeaconObserver!
    private var toneURLs = [NSURL]()
    
    
    var audioPlayersById: [String: AVAudioPlayer] = [String: AVAudioPlayer]();
    
    init(hostView: SignalSelectorDisplay) {
        self.hostView = hostView
        super.init()
        scanner = BeaconObserver.init(signalDelegate: self)
        loadTones()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadTones(){
        let toneNames = ["500Hz","550Hz","600Hz","650Hz","700Hz","750Hz","800Hz","850Hz","900Hz","950Hz","1000Hz"]
        for name in toneNames{
            if let soundFilePath = loadWavWithString(name){
                let fileURL = NSURL.init(fileURLWithPath:(soundFilePath))
                toneURLs.append(fileURL)
            }
        }
    }
    
    func loadWavWithString(name:String) ->String?{
        return NSBundle.mainBundle().pathForResource(name, ofType: "wav")
    }
    
    func getToneAtIndex(index:Int) -> NSURL?{
        if (index < toneURLs.count){
            return toneURLs[index];
        }
        
        return nil;
    }
    
    func createAudioPlayerWithIdentifier(identifier: String, andAudioFileURL fileURL:NSURL){
        do{
            let newPlayer = try AVAudioPlayer.init(contentsOfURL: fileURL)
            addAudioPlayer(newPlayer, withIdentifier: identifier)
        }catch{
            print("cannot create audioPlayer")
        }
    }
    
    func removeToneForIdentifier(identifier: String){
        audioPlayersById.removeValueForKey(identifier);
        scanner.resetBandMembers([String](audioPlayersById.keys))
    }
    
    
    func addAudioPlayer(player:AVAudioPlayer, withIdentifier identifier:String){
        audioPlayersById[identifier] = player;
        scanner.resetBandMembers([String](audioPlayersById.keys))
    }
    
    func updateRangedSignals(signalsByRssi:[String:Beacon]){
        
        var signals = Array(signalsByRssi.values)
        signals.sortInPlace {$0.name.compare($1.name) == .OrderedAscending}
        dispatch_async(dispatch_get_main_queue(),{
            self.hostView.didReceivedNewSignalsToDisplay(signals);
        });
    }
    
    func didRecieveSignalUpdateWithIdentifer(identifier: String, andRSSI rssi:Int){
        
        if let playerTimer = playerTimers[identifier]{
            playerTimer.invalidate()
        }
        let newPlayerTimer = NSTimer.init(timeInterval: 3.0, target: self, selector: #selector(cancelPlayer), userInfo: identifier, repeats:false)
        NSRunLoop.mainRunLoop().addTimer(newPlayerTimer, forMode: NSDefaultRunLoopMode)
        playerTimers[identifier] = newPlayerTimer
        
        var volume: Float = 0
        
        switch rssi {
        case 0:
            volume = 0
        case 1:
            volume = 1.0
        case 2:
            volume = 0.2
        case 3:
            volume = 0.01
        default:
            volume = 0
        }
        playAudioPlayerWithIdentifier(identifier, atVolume: volume)
    }

    private func playAudioPlayerWithIdentifier(identifier:String, atVolume vol:Float){
        if let currentPlayer = self.audioPlayersById[identifier]{
            currentPlayer.volume = vol
            
            //If we're not currently playing start the tone, otherwise reset it to the beginning 
            if(!currentPlayer.playing){
                currentPlayer.play()
            }else{
                currentPlayer.currentTime = 0.5
            }
        }
        
    }
    
    func cancelPlayer(timer: NSTimer){
        print("stopping playback")
        if let identifier = timer.userInfo as? String{
            if let currentPlayer = self.audioPlayersById[identifier]{
                if(currentPlayer.playing){
                    currentPlayer.stop()
                }
                
            }
        }
    }

}
