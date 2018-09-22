//
//  ViewController.swift
//  Uptime
//
//  Created by John Topley on 29/10/2016.
//  Copyright © 2016 John Topley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    enum Colour: Int {
        case white
        case cyan
        case green
        case magenta
        case orange
        case red
        case yellow
    }
    
    let COLOUR_MAPPINGS: [Colour: UIColor] = [.white: .white,
                                              .cyan: .cyan,
                                              .green: .green,
                                              .magenta: .magenta,
                                              .orange: .orange,
                                              .red: .red,
                                              .yellow: .yellow]
    
    let SECONDS_IN_DAY:     Int = 84200
    let SECONDS_IN_HOUR:    Int = 3600
    let SECONDS_IN_MINUTE:  Int = 60
    
    let USER_DEFAULTS_KEY: String = "colour"
    
    @IBOutlet weak var uptimeLabel: UILabel!
    var currentColour: Colour!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        uptimeLabel.font = UIFont(name: "DBLCDTempBlack", size: 48.0)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        registerTapGestureRecognizer()
        currentColour = colourFromUserDefaults()
        updateLabelColour()
        updateLabel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        super.viewDidDisappear(animated)
    }
    
    func colourFromUserDefaults() -> Colour {
        return Colour(rawValue: UserDefaults.standard.integer(forKey: USER_DEFAULTS_KEY)) ?? .white
    }
    
    func nextColour() -> Colour {
        
        // Wrap around back to the first colour.
        if currentColour == .yellow {
            return .white
        }
        
        return Colour(rawValue: currentColour.rawValue + 1)!
    }
    
    func registerTapGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func updateLabel() {
        let FORMAT = "%02d"
        let (days, hours, mins, secs) = secondsToDaysHoursMinutesSeconds(seconds: uptime())
        let paddedDays  = String(format: FORMAT, days)
        let paddedHours = String(format: FORMAT, hours)
        let paddedMins  = String(format: FORMAT, mins)
        let paddedSecs  = String(format: FORMAT, secs)
        uptimeLabel.text = "\(paddedDays):\(paddedHours):\(paddedMins):\(paddedSecs)"
    }
    
    func updateLabelColour() {
        uptimeLabel.textColor = COLOUR_MAPPINGS[currentColour]
    }
    
    func secondsToDaysHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int, Int) {
        let days  = seconds / SECONDS_IN_DAY
        let hours = (seconds % SECONDS_IN_DAY) / SECONDS_IN_HOUR
        let mins  = (seconds % SECONDS_IN_HOUR) / SECONDS_IN_MINUTE
        let secs  = (seconds % SECONDS_IN_HOUR) % SECONDS_IN_MINUTE
        return (days, hours, mins, secs)
    }

    // See http://stackoverflow.com/a/36204651/
    func uptime() -> time_t {
        var bootTime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout<timeval>.stride
        
        var now = time_t()
        var uptime: time_t = -1
        
        time(&now)
        
        if sysctl(&mib, 2, &bootTime, &size, nil, 0) != -1 && bootTime.tv_sec != 0 {
            uptime = now - bootTime.tv_sec
        }
        
        return uptime
    }
    
    @objc func viewTapped(_ gestureRecognizer: UIGestureRecognizer) {
        currentColour = nextColour()
        updateLabelColour()
        UserDefaults.standard.set(currentColour.rawValue, forKey: USER_DEFAULTS_KEY)
    }
}
