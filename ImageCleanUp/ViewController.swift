//
//  ViewController.swift
//  ImageCleanUp
//
//  Created by taeil on 12/04/2019.
//  Copyright © 2019 taeil. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var tv_path: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    // Acions
    @IBAction func actionSelectPath(_ sender: Any) {
        let dialog:NSOpenPanel = NSOpenPanel();
        dialog.title                   = "Choose path...";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = true;
        dialog.canChooseDirectories    = true;
        dialog.canChooseFiles          = false;
        dialog.allowsMultipleSelection = false;
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                
                tv_path.stringValue = path
            }
        } else {
            return
        }
    }
    
    @IBAction func actionStart(_ sender: Any) {
        let path:NSString = tv_path.stringValue as NSString
        
        let fm = FileManager.default
        
        do {
            let items = try fm.contentsOfDirectory(atPath: path as String)
            
            for item in items {
                print("--- Found \(item)")
                
                if item == ".DS_Store" {
                    continue
                }
                
                let filePath = "\(path)/\(item)"
                let attributes = try fm.attributesOfItem(atPath: filePath)
                let type = attributes[FileAttributeKey.type] as! FileAttributeType
                let createDate = attributes[FileAttributeKey.creationDate] as! Date
                
                if (type == FileAttributeType.typeRegular) {
                    // 일반 파일
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let dateString = dateFormatter.string(from: createDate)
                    
                    print("createDate : \(dateString)")
                    
                    let fullPath = path.appendingPathComponent(dateString)
                    
                    // 폴더 생성
                    if FileManager.SearchPathDirectory.desktopDirectory.createSubFolder(absolutePath: fullPath) {
                        // 파일 복사
                        let sourceUrl = URL(fileURLWithPath: filePath)
                        let targetUrl = URL(fileURLWithPath: "\(fullPath)/\(item)")
                        
                        do {
                            try fm.copyItem(at: sourceUrl, to: targetUrl)
                        }
                        catch {
                        }
                        
                    }
                }
            }
        } catch {
            print("Error")
        }
    }
}


extension FileManager.SearchPathDirectory {
    func createSubFolder(absolutePath: String, withIntermediateDirectories: Bool = false) -> Bool {
        let url = URL(fileURLWithPath: absolutePath)
        
        var isDir : ObjCBool = false
        
        if FileManager.default.fileExists(atPath: absolutePath, isDirectory: &isDir) {
            return true
        }
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories, attributes: nil)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
