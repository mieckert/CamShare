import SwiftUI
import Cocoa
import AVFoundation
import HotKey

class SettingsManager: ObservableObject {
    var availableCameras: [AVCaptureDevice] = []
    @Published var selectedCameraIdx: Int = -1
    @Published var hideControlsInBrowserTab = true

    init() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external], mediaType: .video, position: .unspecified)
        
        availableCameras = discoverySession.devices
        
        if !availableCameras.isEmpty {
            selectedCameraIdx = 0
            for (idx,camera) in availableCameras.enumerated() {
                print("localizedName = \(camera.localizedName)")
                if(camera.localizedName.contains("JOURIST")) {
                    print("found")
                    selectedCameraIdx = idx
                    print("selectedCameraIdx = \(selectedCameraIdx)")
                    break
                }
            }
        }
    }
    
    public func getCam() -> AVCaptureDevice {
        return availableCameras[selectedCameraIdx]
    }
}

@main
struct CamShareApp: App {
    var webServer: WebServer?
    @ObservedObject var settingsManager = SettingsManager()
    
    var hotKeyD = HotKey(key: .d, modifiers: [.command, .control, .shift])
    var hotKeyE = HotKey(key: .e, modifiers: [.command, .control, .shift])
    var hotKeyF = HotKey(key: .f, modifiers: [.command, .control, .shift])
    var hotKeyR = HotKey(key: .r, modifiers: [.command, .control, .shift])


    init() {
        print("App starting")
        webServer = WebServer(settingsManager: settingsManager)
        
        hotKeyD.keyDownHandler = focusAndExposure
        hotKeyF.keyDownHandler = focus
        hotKeyE.keyDownHandler = exposure
        hotKeyR.keyDownHandler = openTabInBrowser
    }
    
    var body: some Scene {
        MenuBarExtra("CAM", image: "icon16x16") {
            Button("Open tab in browser", action: openTabInBrowser)
            Toggle("Hide Controls in Browser", isOn: $settingsManager.hideControlsInBrowserTab)
            Divider()
            Picker("Camera", selection: $settingsManager.selectedCameraIdx) {
                Text("None").tag(-1)
                ForEach(Array(settingsManager.availableCameras.indices), id: \.self) {
                    Text(self.settingsManager.availableCameras[$0].localizedName).tag($0)
                }
            }
            Divider()
            Button("Dial-in everything", action: focusAndExposure)
            Divider()
            Button("Focus", action: focus)
            Button("Exposure", action: exposure)
            Divider()
            Button("Check Format", action: checkFormat)
            Divider()
            Button("Quit", action: quit)
        }
    }
        
    func openTabInBrowser() {
        print("Opening Browser Tab")
        let url: URL = URL(string: "http://localhost:3113")!
        let _ = NSWorkspace.shared.open(url)
    }
    
    func checkFormat() {
        do {
            let cam = settingsManager.getCam()
            try cam.lockForConfiguration()
            
            print(cam.formats)
            print(cam.activeFormat)
            
            cam.unlockForConfiguration()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }

    
    func focus() {
        do {
            let cam = settingsManager.getCam()
            
            if !cam.isFocusModeSupported(.continuousAutoFocus) {
                print("Continous Auto Focus is not supported")
                return
            }
            if !cam.isFocusModeSupported(.locked) {
                print("Locked is not supported")
                return
            }
            
            try cam.lockForConfiguration()
            cam.focusMode = .continuousAutoFocus
            sleep(2)
            cam.focusMode = .locked
            
            cam.unlockForConfiguration()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
        
    func exposure() {
        do {
            let cam = settingsManager.getCam()
            
            if !cam.isExposureModeSupported(.continuousAutoExposure) {
                print("Continous Auto Exposure is not supported")
                return
            }
            if !cam.isExposureModeSupported(.locked) {
                print("Locked is not supported")
                return
            }
            
            try cam.lockForConfiguration()
            cam.exposureMode = .continuousAutoExposure
            sleep(2)
            cam.exposureMode = .locked
            cam.unlockForConfiguration()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func focusAndExposure() {
        do {
            let cam = settingsManager.getCam()
            
            if !cam.isFocusModeSupported(.continuousAutoFocus) {
                print("Continous Auto Focus is not supported")
                return
            }
            if !cam.isFocusModeSupported(.locked) {
                print("Auto Focus Locked is not supported")
                return
            }
            if !cam.isExposureModeSupported(.continuousAutoExposure) {
                print("Continous Auto Exposure is not supported")
                return
            }
            if !cam.isExposureModeSupported(.locked) {
                print("Exposure Locked is not supported")
                return
            }
            
            try cam.lockForConfiguration()
            cam.exposureMode = .continuousAutoExposure
            cam.focusMode = .continuousAutoFocus
            sleep(4)
            cam.focusMode = .locked
            cam.exposureMode = .locked

            cam.unlockForConfiguration()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }

    
    func quit() { NSApplication.shared.terminate(nil) }
}
