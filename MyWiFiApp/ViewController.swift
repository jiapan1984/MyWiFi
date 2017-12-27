//
//  ViewController.swift
//  MenuBarApp
//
//  Created by 贾攀 on 2017/11/7.
//  Copyright © 2017年 贾攀. All rights reserved.
//

import Cocoa
import Foundation
import CoreWLAN

extension CWChannelBand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .band2GHz: return "2G"
        case .band5GHz: return "5G"
        case .bandUnknown: return "Unknown"
        }
    }
}

extension CWChannelWidth: CustomStringConvertible {
    public var description: String {
        switch  self {
        case .width160MHz:
            return "160MHz"
        case .width20MHz:
            return "20MHz"
        case .width40MHz:
            return "40MHz"
        case .width80MHz:
            return "80MHz"
        default:
            return "Unknown"
        }
    }
}
extension CWPHYMode: CustomStringConvertible {
    public var description: String {
        switch  self {
        case .mode11a:
            return "802.11a"
        case .mode11b:
            return "802.11b"
        case .mode11ac:
            return "802.11ac"
        case .mode11g:
            return "802.11g"
        case .mode11n:
            return "802.11n"
        default:
            return "Unknown"
        }
    }
}

class MyWifi {
    var currentInterface: CWInterface
    var interfacesNames: [String] = []
    var networks: Set<CWNetwork> = []
    let wifiClient = CWWiFiClient.shared()
    
    // Failable init using default interface
    init?() {
        if let defaultInterface = wifiClient.interface(),
            let name = defaultInterface.interfaceName {
            self.currentInterface = defaultInterface
            self.interfacesNames.append(name)
            self.wifiClient.delegate = self
        } else {
            return nil
        }
    }
    var ssid: String {
        return currentInterface.ssid() ?? "Not Connected"
    }
    var rssi: Int {
        return currentInterface.rssiValue()
    }
    var rate: Double {
        return currentInterface.transmitRate()
    }
    var bssid: String {
        return currentInterface.bssid() ?? "Unknown"
    }
    var channel:Int {
        return currentInterface.wlanChannel()?.channelNumber ?? 1
    }
    var channelWidth:String {
        let width = currentInterface.wlanChannel()?.channelWidth ?? .widthUnknown
        return "\(width)"
    }
    var channelBand:String {
        let band = currentInterface.wlanChannel()?.channelBand ?? .bandUnknown
        return "\(band)"
    }
    var hwMac:String {
        return currentInterface.hardwareAddress() ?? "00:00:00:00:00:00"
    }
    var phyMode:String {
        let mode = currentInterface.activePHYMode()
        return "\(mode)"
    }
    // Fetch detectable WIFI networks
    func findNetworks() {
        do {
            self.networks = try currentInterface.scanForNetworks(withSSID: nil)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    func startMonitorEvent(_ delegate: CWEventDelegate) {
        do {
            self.wifiClient.delegate = delegate
            print("Start Monitor event!")
            try self.wifiClient.startMonitoringEvent(with: .bssidDidChange)
            try self.wifiClient.startMonitoringEvent(with: .linkDidChange)
            try self.wifiClient.startMonitoringEvent(with: .countryCodeDidChange)
            try self.wifiClient.startMonitoringEvent(with: .linkQualityDidChange)
            try self.wifiClient.startMonitoringEvent(with: .modeDidChange)
            try self.wifiClient.startMonitoringEvent(with: .powerDidChange)
            // try self.wifiClient.startMonitoringEvent(with: .rangingReportEvent)
            try self.wifiClient.startMonitoringEvent(with: .scanCacheUpdated)
            try self.wifiClient.startMonitoringEvent(with: .ssidDidChange)
            // try self.wifiClient.startMonitoringEvent(with: .virtualInterfaceStateChanged)
            
        } catch {
            print("Start error: \(error.localizedDescription)")
        }
        
    }
    
    func stopMonitorEvent() {
        do {
            try self.wifiClient.stopMonitoringAllEvents()
        } catch {
            print("Stop error: \(error.localizedDescription)")
        }
    }
    
}

extension MyWifi: CWEventDelegate {
    func bssidDidChangeForWiFiInterface(withName interfaceName: String) {
        if let bssid = self.currentInterface.bssid() {
            print("Intf (\(interfaceName)) BSSID has changed , current BSSID is: \(bssid)")
        }
    }
    func clientConnectionInterrupted() {
        /* Tells the delegate that the connection to the Wi-Fi subsystem is temporarily interrupted. */
        print("clientConnectionInterrupted")
    }
    
    func clientConnectionInvalidated() {
        /* Tells the delegate that the connection to the Wi-Fi subsystem is permanently invalidated. */
        print("clientConnectionInvalidated")
    }

    func countryCodeDidChangeForWiFiInterface(withName interfaceName: String) {
        /* Tells the delegate that the currently adopted country code has changed. */
        print("countryCodeDidChangeForWiFiInterface")
    }
    func linkDidChangeForWiFiInterface(withName interfaceName: String) {
        /* Tells the delegate that the Wi-Fi link state changed.  */
        print("linkDidChangeForWiFiInterface")
    }
    func linkQualityDidChangeForWiFiInterface(withName interfaceName: String, rssi: Int, transmitRate: Double) {
        /* */
        print("Intf (\(interfaceName)) link qualitity changed RSSI:\(rssi), rate:\(transmitRate)")
    }
    func modeDidChangeForWiFiInterface(withName interfaceName: String) {
        print("modeDidChangeForWiFiInterface")
    }
    func powerStateDidChangeForWiFiInterface(withName interfaceName: String) {
        print("powerStateDidChangeForWiFiInterface")
    }
    func rangingReportEventForWiFiInterface(withName interfaceName: String, data rangingData: [Any], error err: Error) {
        print("rangingReportEventForWiFiInterface")
    }
    func scanCacheUpdatedForWiFiInterface(withName interfaceName: String) {
        print("scanCacheUpdatedForWiFiInterface")
    }
    
    func ssidDidChangeForWiFiInterface(withName interfaceName: String) {
        if let ssid = self.currentInterface.ssid() {
            print("Intf (\(interfaceName)) SSID has changed , current SSID is: \(ssid)")
        }
    }
    func virtualInterfaceStateChangedForWiFiInterface(withName interfaceName: String) {
        print("virtualInterfaceStateChangedForWiFiInterface")
    }
}


class ViewController: NSViewController {
    var myWifi: MyWifi?
    @IBOutlet weak var ssidLabel: NSTextField!
    @IBOutlet weak var rateLabel: NSTextField!
    @IBOutlet weak var rssiLabel: NSTextField!
    @IBOutlet weak var bssidLabel: NSTextField!
    @IBOutlet weak var channelLabel: NSTextField!
    @IBOutlet weak var channelWidthLabel: NSTextField!
    @IBOutlet weak var myMacLabel: NSTextField!
    @IBOutlet weak var channelBandLabel: NSTextField!
    @IBOutlet weak var phyModeLabel: NSTextField!
    
    func updateWifiInfo() {
        if let myWifi = myWifi {
            ssidLabel.stringValue = myWifi.ssid
            rateLabel.stringValue = String(myWifi.rate)
            rssiLabel.stringValue = String(myWifi.rssi)
            bssidLabel.stringValue = myWifi.bssid.uppercased()
            channelLabel.stringValue = String(myWifi.channel)
            channelWidthLabel.stringValue = myWifi.channelWidth
            channelBandLabel.stringValue = myWifi.channelBand
            myMacLabel.stringValue = myWifi.hwMac.uppercased()
            phyModeLabel.stringValue = myWifi.phyMode
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if myWifi == nil {
            myWifi = MyWifi()
            myWifi?.startMonitorEvent(self)
        }
        updateWifiInfo()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: CWEventDelegate {
    func bssidDidChangeForWiFiInterface(withName interfaceName: String) {
        DispatchQueue.main.async {
            self.updateWifiInfo()
        }
    }
    func clientConnectionInterrupted() {
        /* Tells the delegate that the connection to the Wi-Fi subsystem is temporarily interrupted. */
        print("clientConnectionInterrupted")
    }
    
    func clientConnectionInvalidated() {
        /* Tells the delegate that the connection to the Wi-Fi subsystem is permanently invalidated. */
        print("clientConnectionInvalidated")
    }
    
    func countryCodeDidChangeForWiFiInterface(withName interfaceName: String) {
        /* Tells the delegate that the currently adopted country code has changed. */
        print("countryCodeDidChangeForWiFiInterface")
    }
    func linkDidChangeForWiFiInterface(withName interfaceName: String) {
        /* Tells the delegate that the Wi-Fi link state changed.  */
        DispatchQueue.main.async {
            self.updateWifiInfo()
        }
    }
    func linkQualityDidChangeForWiFiInterface(withName interfaceName: String, rssi: Int, transmitRate: Double) {
        /* */
        print("Intf (\(interfaceName)) link qualitity changed RSSI:\(rssi), rate:\(transmitRate)")
        DispatchQueue.main.async {
            self.updateWifiInfo()
        }
    }
    func modeDidChangeForWiFiInterface(withName interfaceName: String) {
        print("modeDidChangeForWiFiInterface")
        DispatchQueue.main.async {
            self.updateWifiInfo()
        }
    }
    func powerStateDidChangeForWiFiInterface(withName interfaceName: String) {
        print("powerStateDidChangeForWiFiInterface")
    }
    func rangingReportEventForWiFiInterface(withName interfaceName: String, data rangingData: [Any], error err: Error) {
        print("rangingReportEventForWiFiInterface")
    }
    func scanCacheUpdatedForWiFiInterface(withName interfaceName: String) {
        print("scanCacheUpdatedForWiFiInterface")
    }
    
    func ssidDidChangeForWiFiInterface(withName interfaceName: String) {
        DispatchQueue.main.async {
            self.updateWifiInfo()
        }
    }
    func virtualInterfaceStateChangedForWiFiInterface(withName interfaceName: String) {
        print("virtualInterfaceStateChangedForWiFiInterface")
    }
}

extension ViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> ViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("PopViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}

