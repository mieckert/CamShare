//
//  WebServer.swift
//  CamShare
//
//  Created by Michael Eckert on 15.02.23.
//

import Foundation
import Swifter
import SwiftUI

class WebServer {
    var server: HttpServer
    @ObservedObject var settingsManager: SettingsManager
    
    init(settingsManager: SettingsManager) {
        do {
            self.settingsManager = settingsManager
            server = HttpServer()
            print("bundlePath = \(Bundle.main.bundlePath)")
            print("resourcePath = \(Bundle.main.resourcePath!)")

            let indexPath = Bundle.main.path(forResource: "index", ofType: "html")!
            print("indexPath = \(indexPath)")
            server["/"]           = shareFile(Bundle.main.path(forResource: "index", ofType: "html")!)
            server["/index.html"] = shareFile(Bundle.main.path(forResource: "index", ofType: "html")!)
            server["/index.css"]  = shareFile(Bundle.main.path(forResource: "index", ofType: "css")!)
            server["/index.js"]   = shareFile(Bundle.main.path(forResource: "index", ofType: "js")!)


            server["/resources/:path"] = shareFilesFromDirectory(Bundle.main.resourcePath!)
            
            //server["/:path"] = shareFilesFromDirectory("/Users/meckert/dev/camshare-local/static")

            // server["/resources/(.+)"] = NSBundle.mainBundle().resourcePath

            server["/rest/getSettings"] = { req in
                let cam = self.settingsManager.availableCameras[self.settingsManager.selectedCameraIdx]
                let hide = self.settingsManager.hideControlsInBrowserTab
                let data = [ 
                    "camName": cam.localizedName,
                    "camModelId": cam.modelID,
                    "camUniqueId": cam.uniqueID,
                    "camDescription": cam.description,
                    "hide": hide
                ]
                return .ok(.json(data))
            }
            
            try server.start(3113)
        }
        catch {
            print("Ooops")
            print("Unexpected error: \(error).")
        }
    }
}
