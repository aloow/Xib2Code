//
//  ViewController.swift
//  Xib2Code
//
//  Created by iMac on 2020/9/3.
//  Copyright © 2020 iMac. All rights reserved.
//

import Cocoa
import SwiftyJSON
import SWXMLHash

class ViewController: NSViewController {

    var viewControllerInfo: ViewControllerInfo?
    var viewControllerInfos = [ViewControllerInfo]()
    
    @IBOutlet weak var inputScrollerView: NSScrollView!
    
    @IBOutlet weak var hFileName: NSTextField!
    @IBOutlet weak var mFileName: NSTextField!
    
    @IBOutlet weak var inputTextView: NSTextView!
    @IBOutlet weak var houtputSTextView: NSTextView!
    @IBOutlet weak var moutputTextView: NSTextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextView(textview: inputTextView)
        setupTextView(textview: houtputSTextView)
        setupTextView(textview: moutputTextView)
        
    }

    func setupTextView(textview:NSTextView) {
        
        textview.lnv_setUpLineNumberView()
        textview.font = NSFont.userFixedPitchFont(ofSize: NSFont.smallSystemFontSize)
        textview.font = NSFont.systemFont(ofSize: 16.0)
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK:User touch
    
    @IBAction func setupInputText(_ sender: Any) {
    
//        if let result = getString() {
//            inputTextView.string = result
//        }
        if let result = getXmlString() {
            inputTextView.string = result
        }
        
    }
    
    @IBAction func generateTap(_ sender: Any) {
        
        
        
        
    }
    
    @IBAction func selectFile(_ sender: Any) {
        
    }
    
    // String -> Json
    func jsonToFile(jsonString:String) {
        // MARK: xib
        // input string to json
        let inputString = inputTextView.string
        if inputString.isEmpty {
            return
        }

        let xibJson = JSON(parseJSON: inputString)
                    
        let vcJson = xibJson["document"]["objects"]

        // self.viewControllerInfos.append(ViewControllerInfo(withXib: vcJson))

        self.viewControllerInfo = ViewControllerInfo(withXib: vcJson)
        guard let vcInfo = self.viewControllerInfo else { return }

        // 生成.h .m
        hFileName.stringValue = vcInfo.filehName
        houtputSTextView.string = vcInfo.fileh

        mFileName.stringValue = vcInfo.filemName
        moutputTextView.string = vcInfo.filem
    }
    
}


// MARK: Tool
extension ViewController {
    
    /// JSON代表一个ViewController
    func getStoryBoardJson(from filename:String = "Vipsb") -> [JSON]? {
        
        guard let vipJson = getJsonFile(with: filename) else {
            print("get vip \(filename) error")
            return nil
        }
        
        var vcJson = [JSON]()
        if let objects = vipJson["document"]["scenes"]["scene"].array {
            vcJson = objects
        } else {
            vcJson.append(vipJson["document"]["scenes"]["scene"])
        }
        
        guard !vcJson.isEmpty else {
            print("scenes is empty error")
            return nil
        }
        
        return vcJson
    }
    
    /// JSON代表一个ViewController
    func getXibJson(from filename:String = "Vipsb") -> JSON? {
        
        guard let vipJson = getJsonFile(with: filename) else {
            print("get vip \(filename) error")
            return nil
        }
        
        return vipJson["document"]["objects"]
        
    }
    
    /// JSON代表一个ViewController
    func getXibXml(from filename:String = "Vipsb") -> XMLIndexer? {
        
        guard let vipXml = getXmlFile(with: filename) else {
            print("get vip \(filename) error")
            return nil
        }
        return vipXml["document"]["objects"]
        
    }
    
    
    //  创建一个方法，用来创建文本文件
    func write(text info:String?,to filename:String?) {
        
        guard let info = info, !info.isEmpty else {
            print("\(filename!)文本的内容为空")
            return
        }
        guard let filename = filename, !filename.isEmpty else {
            print("文化名为空")
            return
        }
        
        // 创建一个字符串对象，表示文档目录下的一个文本文件
        let filepath:String = NSHomeDirectory() + "/Documents/\(filename)"
        // 再次创建一个字符串对象，用来储存将要写入的文本内容
        print(filepath)
        do{
            // 将文本文件写入到指定位置的文本文件，并且使用utf-8的编码方式
            try info.write(toFile: filepath, atomically: true, encoding: .utf8)
            print("Success to write a file.\n")
        }catch{
            print("Error to write a file.\n")
        }
    }
    
    func getJsonFile(with filename:String = "Vipsb") -> JSON? {
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonData = try JSON.init(data: data)
                return jsonData
            } catch {
                // maybe lets throw error here
                return nil
            }
        }
        return nil
    }
    
    func getXmlFile(with filename:String = "Vipsb") -> XMLIndexer? {
        if let path = Bundle.main.path(forResource: filename, ofType: "xml") {
            
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let xml = SWXMLHash.parse(data)
                return xml
            } catch {
                // maybe lets throw error here
                return nil
            }
        }
        return nil
    }
    
    func getString(with filename:String = "Vipsb") ->String? {
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let result = String(data: data, encoding: .utf8)
                return result
            } catch {
                // maybe lets throw error here
                return nil
            }
        }
        return nil
    }
    
    func getXmlString(with filename:String = "Vipsb") ->String? {
        if let path = Bundle.main.path(forResource: filename, ofType: "xml") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let result = String(data: data, encoding: .utf8)
                return result
            } catch {
                // maybe lets throw error here
                return nil
            }
        }
        return nil
    }
    
    
}
