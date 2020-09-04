//
//  Model.swift
//  Xib2Code
//
//  Created by iMac on 2020/8/28.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation
import SwiftyJSON
import SWXMLHash

struct ViewControllerInfo {
    
    var typeString : String = "ViewController" //"-customClass"
    var view : ViewInfo? // Root View
    
    init(withSb json:JSON) {
        
        guard let viewControllerInfoDic = json["objects"]["viewController"].dictionary else {
            return
        }
        // 获取vc的类型
        if let vcType = viewControllerInfoDic["-customClass"]?.string {
            self.typeString = vcType
        }
        self.view = ViewInfo(json: json["objects"]["viewController"]["view"], type: "UIView")
        
    }
    
    init(withXib xibJson:JSON) {
        self.view = ViewInfo(json: xibJson["view"], type: "View")
    }
    
    init(withXib xibXml:XMLIndexer) {
        self.view = ViewInfo(xml: xibXml["view"], type: "View")
    }
    
    // .h文件
    var fileh: String {
        
        return """
        //
        //  \(typeString).h
        //  \(projectName)
        //
        //  Created by iMac on \(dateText).
        //  Copyright © 2020 iMac. All rights reserved.
        //
        
        #import <UIKit/UIKit.h>
        
        NS_ASSUME_NONNULL_BEGIN
        
        @interface \(typeString) : UIViewController
        
        @end
        
        NS_ASSUME_NONNULL_END
        """
        
    }
    
    // MARK: .m文件
    // .m文件对应的字符串
    var filem: String {
        
        return """
        //
        //  \(typeString).m
        //  \(projectName)
        //
        //  Created by iMac on \(dateText).
        //  Copyright © 2020 iMac. All rights reserved.
        //
        
        #import "\(typeString).h"
        #import <Masonry.h>
        
        @interface \(typeString) ()
        
        \(getPropertyToString(from: view, isRootView: true))
        
        @end
        
        @implementation \(typeString)
        
        - (void)viewDidLoad {
        [super viewDidLoad];
        
        
        }
        
        // MARK: 布局UI
        - (void)layoutSubviews {
        
        \(generateConstraints(from: view, isRootView: true))
        
        }
        
        // MARK: UI
        \(generateUI(from: view, isRootView: true))
        
        @end
        """
        
    }
    
    
    // property (type,name) 对应的字符串
    func getPropertyToString(from view:ViewInfo?, isRootView:Bool = false) -> String {
        
        guard let view = view else { return "" }
        
        var result = ""
        result = result + "\n@property (nonatomic, strong) \(view.type.full) *\(view.realName);\n"
        
        if isRootView {
            result = ""
        }
        
        if view.subviews.isEmpty {
            return result
        }
        for view in view.subviews {
            result = result + getPropertyToString(from: view)
        }
        
        return result
        
    }
    
    // 单个View生成
    func generateUI(from view:ViewInfo?, isRootView:Bool = false) -> String {
        
        guard let view = view else { return "" }
        
        var result = ""
        
        var uiItme: String = ""
        switch view.type {
        case .label:
            uiItme = """
            
            - (UILabel *)\(view.realName) {
                if (!_\(view.realName)) {
                _\(view.realName) = [[UILabel alloc] init];
                _\(view.realName).text = @"\(view.text ?? "")";
                _\(view.realName).font = [UIFont boldSystemFontOfSize:\(view.fontSize ?? "0")];
                }
                return _\(view.realName);
            }
            
            """
        case .button:
            uiItme = """
            
            - (UIButton *)\(view.realName) {
                if (!_\(view.realName)) {
                _\(view.realName) = [[UIButton alloc] init];
                [_\(view.realName) setTitle:@"\(view.title ?? "")" forState:UIControlStateNormal];
                }
                return _\(view.realName);
            }
            
            """
        case .view:
            uiItme = """
            
            - (UIView *)\(view.realName) {
                if (!_\(view.realName)) {
                _\(view.realName) = [[UIView alloc] init];
                }
                return _\(view.realName);
            }
            
            """
        case .imageView:
            uiItme = """
            
            - (UIImageView *)\(view.realName) {
                if (!_\(view.realName)) {
                _\(view.realName) = [[UIImageView alloc] init];
                _\(view.realName).contentMode = \(view.contentMode.string);
                _\(view.realName).image = [UIImage imageNamed:@"\(view.image ?? "")"];
                }
                return _\(view.realName);
            }
            
            """
        case .scrollView:
            uiItme = """
            
            - (UIScrollView *)\(view.realName) {
                if (!_\(view.realName)) {
                _\(view.realName) = [[UIScrollView alloc] init];
                _\(view.realName).backgroundColor = [UIColor blackColor];
                _\(view.realName).contentSize = CGSizeMake(_scrollView.frame.size. width, _\(view.realName).frame.size.height);
                }
                return _\(view.realName);
            }
            
            """
        case .stackView:
            // subviews
            guard view.subviews.count > 0 else { break }
            let subViews = view.subviews.map({ (viewInfo) -> String in
                return "self." + viewInfo.realName
            })
            
            uiItme = """
            
            - (UIStackView *)\(view.realName) {
                if (!_\(view.realName)) {
                NSArray *views = @[\(subViews.joined(separator: ","))];
                _\(view.realName) = [[UIStackView alloc] initWithArrangedSubviews:views];
                _\(view.realName).axis = \(view.axis.string);
                _\(view.realName).alignment = \(view.alignment.string);
                _\(view.realName).distribution = \(view.distribution.string);
                _\(view.realName).spacing = \(view.spacing);
                }
                return _containerStackView;
            }
            
            """
        }
        
        result = result + uiItme
        
        if isRootView {
            result = ""
        }
        
        if view.subviews.isEmpty {
            return result
        }
        for view in view.subviews {
            result = result + generateUI(from: view)
        }
        
        return result
        
    }
    
    // 约束生成 Container
    func generateConstraints(from view:ViewInfo?, isRootView:Bool = false) -> String {
        
        guard let view = view else { return "" }
        
        var result = ""
        
        if view.type != .stackView {
            view.subviews.forEach { (subviewInfo) in
                result = result + "[self.\(view.realName) addSubview:self.\(subviewInfo.realName)];\n"
            }
            result = result + "\n"
        }
        
        if view.subviews.isEmpty {
            return result
        }
        
        for view in view.subviews {
            result = result + generateConstraints(from: view)
        }
        
        return result
    }
    
    
    // MARK: Convenience
    var filehName: String {
        return self.typeString + ".h"
    }
    
    var filemName: String {
        return self.typeString + ".m"
    }
    
    // MARK: Tool
    // 时间对应的字符串
    var dateText: String {
        let date = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat="yyyy/MM/dd"
        let dateText = dateFormat.string(from: date)
        return dateText
    }
    
    var projectName: String {
        
        var result = ""
        guard let infoDictionary = Bundle.main.infoDictionary else {
            return result
        }
        guard let projectName = infoDictionary["CFBundleExecutable"] as? String else {
            return result
        }
        result = projectName
        
        return result
    }
    
    
}


//
struct ViewInfo {
    
    var subviews = [ViewInfo]()
    
    var id:String = ""
    
    var rest_y: Int! // 判断图层位置 "rect""-y"
    var type = ViewType.view  // type:view .full:UIView
    var name: String?
    var realName: String {
        guard var name = name,
            name.count > 0 else { return "name_nil" }
        name = name.replacingOccurrences(of: " ", with: "")
        var firstC = ""
        firstC.append(name.removeFirst())
        firstC = firstC.lowercased()
        return firstC + name
    }
    
    // UIStackView
    var axis: AxisType = AxisType.horizontal
    var alignment: AlignmentType = AlignmentType.fill
    var distribution = DistributionType.fill
    var spacing: String = "0"
    
    // UIImage
    var image: String?
    var contentMode = ContentModeTpye.scaleAspectFit
    
    // UILabel -text
    var text: String?
    var fontSize: String? // 16
    var color: String?
    
    // UIButton
    var title: String?
    var bimage: String?
    
    var constraints = [Constraint]()
    
    init(json: JSON, type: String) {
        
        self.id = json["-id"].string ?? ""
        
        self.type = ViewType(rawValue: type) ?? .view
        
        if let subViewsDic = json["subviews"].dictionary {
            subViewsDic.keys.forEach { (key) in
                if let item = subViewsDic[key]?.array {
                    item.forEach { (json) in
                        subviews.append(ViewInfo.init(json: json, type: key))
                    }
                } else if let json = subViewsDic[key] {
                    subviews.append(ViewInfo.init(json: json, type: key))
                }
            }
        }
        
        subviews.sort(by: { (view1, view2) -> Bool in
            view1.rest_y < view1.rest_y
        })
        
        image = json["-image"].string
        contentMode = ContentModeTpye(rawValue: json["-contentMode"].string ?? "")
            ?? .scaleAspectFit
        
        rest_y = Int(json["rect"]["-y"].string ?? "") ?? 0
        
        name = json["-userLabel"].string ?? type
        
        // 有值则为vertical，无值是默认
        if let _ = json["-axis"].string {
            axis = .vertical
        }
        spacing = json["-spacing"].string ?? "0"
        
        if let alignment = json["-alignment"].string,
            let distribution = json["-distribution"].string {
            self.alignment = AlignmentType(rawValue: alignment) ?? .fill
            self.distribution = DistributionType(rawValue: distribution) ?? .fill
        }
        
        text = json["-text"].string
        fontSize = json["fontDescription"]["-pointSize"].string
        color = json["color"]["-key"].string
        
        title = json["state"]["-title"].string
        bimage = json["state"]["-image"].string
        // 约束
        if let constraintsJson = json["constraints"]["constraint"].array {
            constraintsJson.forEach { (json) in
                constraints.append(Constraint(with: json))
            }
        }
        
    }
    
    init(xml: XMLIndexer, type: String) {
        
        self.id = xml.element?.attribute(by: "id")?.text ?? ""
        
        self.type = ViewType(rawValue: type) ?? .view
        
        let subXmlViews = xml["subviews"].children
        subXmlViews.forEach { (xmlIndeter) in
            subviews.append(ViewInfo(xml: xmlIndeter, type: xmlIndeter.element?.name ?? ""))
        }
      
        image = xml.element?.attribute(by: "image")?.text ?? ""
        
        contentMode = ContentModeTpye(rawValue: xml.element?.attribute(by: "contentMode")?.text ?? "")
            ?? .scaleAspectFit
        
        rest_y = Int(xml["rect"].element?.attribute(by: "y")?.text ?? "") ?? 0
        
        name = xml.element?.attribute(by: "userLabel")?.text ?? type
        
        // 有值则为vertical，无值是默认
        if let _ = xml.element?.attribute(by: "axis")?.text {
            axis = .vertical
        }
        spacing =  xml.element?.attribute(by: "spacing")?.text ?? "0"
        
        if let alignment = xml.element?.attribute(by: "alignment")?.text,
            let distribution = xml.element?.attribute(by: "distribution")?.text {
            self.alignment = AlignmentType(rawValue: alignment) ?? .fill
            self.distribution = DistributionType(rawValue: distribution) ?? .fill
        }
        
        text = xml.element?.attribute(by: "text")?.text
        fontSize = xml["fontDescription"].element?.attribute(by: "pointSize")?.text
        color = xml["color"].element?.attribute(by: "key")?.text
        
        title = xml["state"].element?.attribute(by: "title")?.text
        bimage = xml["state"].element?.attribute(by: "image")?.text
        // 约束
        let constraintsXml = xml["constraints"].children
        constraintsXml.forEach { (xml) in
            constraints.append(Constraint(with: xml))
        }
        
    }
    
    //
    var hadSubviews: Bool {
        return !subviews.isEmpty
    }
    
    
}


// 约束 constraints
struct Constraint {
    var firstItem: String
    var firstAttribute: String
    var secondItem: String
    var secondAttribute: String
    var constant: String
    var id: String
    init(with json:JSON) {
        firstItem = json["-firstItem"].string ?? ""
        firstAttribute = json["-firstAttribute"].string ?? ""
        secondItem = json["-secondItem"].string ?? ""
        secondAttribute = json["-secondAttribute"].string ?? ""
        constant = json["-constant"].string ?? ""
        id = json["-id"].string ?? ""
    }
    init(with xml:XMLIndexer) {
        firstItem = xml.element?.attribute(by: "firstItem")?.text ?? ""
        firstAttribute = xml.element?.attribute(by: "firstAttribute")?.text ?? ""
        secondItem = xml.element?.attribute(by: "secondItem")?.text ?? ""
        secondAttribute = xml.element?.attribute(by: "secondAttribute")?.text ?? ""
        constant = xml.element?.attribute(by: "constant")?.text ?? ""
        id = xml.element?.attribute(by: "id")?.text ?? ""
    }
}

