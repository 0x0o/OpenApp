//
//  AppDelegate.swift
//  OpenApp
//
//  Created by 0x0 on 2020/5/7.
//  Copyright © 2020 0x0. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    // 监听logo点击
      @objc func statusBarMouseClicked(sender: NSStatusBarButton) {
          let event = NSApp.currentEvent!
          switch event.type {
          case NSEvent.EventType.leftMouseUp:
            openURL()
          case NSEvent.EventType.rightMouseUp:
            statusItem.menu = statusMenu
            statusItem.popUpMenu(statusMenu)
            statusItem.menu = nil
          default:
              break
          }
      }
     
    
    @IBAction func quit(_ sender: Any) {
       NSApp.terminate(self)
    }
    
    func openURL() {
        let str = getPasteboardTextAndFilter()
               let substr = "macappstore://apps.apple.com/app/"
               let fullstr = substr + str
               if str.count  > 0 {
                   if let url = URL(string: fullstr) {
                       NSWorkspace.shared.open(url)
                   }
               }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            let icon = NSImage(named: NSImage.Name("icon"))
                  icon?.isTemplate = true
                  button.image = icon
                  button.target = self
                  button.action = #selector(self.statusBarMouseClicked(sender:))
                  button.sendAction(on: [.leftMouseUp, .rightMouseUp])
              }
        
    }
    
    func getPasteboardTextAndFilter() -> String {
        let pasteboard = NSPasteboard.general
        var clipboardItems: [String] = []
        for element in pasteboard.pasteboardItems! {
            if let str = element.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) {
                clipboardItems.append(str)
            }
        }

        let firstClipboardItem = clipboardItems[0]
        // filiter https://apps.apple.com/us/app/pixelmator-pro/id1289583905
        let regex = "apps.apple.com"
        let res = RegularExpression(regex: regex, validateString: firstClipboardItem)
        if res.count > 0 {
            let regex = "\\w\\w\\d{7,13}"
            let res = RegularExpression(regex: regex, validateString: firstClipboardItem)
            if res.count > 0 {
                return res[0]
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func RegularExpression (regex:String,validateString:String) -> [String]{
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: validateString, options: [], range: NSMakeRange(0, validateString.count))
            var data:[String] = Array()
            for item in matches {
                let string = (validateString as NSString).substring(with: item.range)
                data.append(string)
            }
            return data
        }
        catch {
            return []
        }
    }
}

