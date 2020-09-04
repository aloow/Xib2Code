//
//  EnumHelper.swift
//  Xib2Code
//
//  Created by iMac on 2020/8/31.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation

// MARK: common
enum ViewType: String {
    case view
    case label
    case button
    case imageView
    case scrollView
    case stackView
    
    var full: String {
        
        switch self {
        case .view:
            return "UIView"
        case .label:
            return "UILabel"
        case .button:
            return "UIButton"
        case .imageView:
            return "UIImageView"
        case .scrollView:
            return "UIScrollView"
        case .stackView:
            return "UIStackView"
        }
        
    }
    
}

// MARK: UIStackView Help
/// UIStackView横向、纵向
enum AxisType: String {
    case vertical // 有值
    case horizontal // 对应key没有值时是这个
    
    var string: String {
        switch self {
        case .vertical:
            return "UILayoutConstraintAxisVertical"
        default:
            return "UILayoutConstraintAxisHorizontal"
        }
    }
    
}

/// UIStackView 
enum AlignmentType: String {
    case fill // 默认
    case leading
    case center
    case trailing
    
    case top
    case bottom
    case firstBaseline
    case lastBaseline
    
    var string: String {
        switch self {
        case .fill:
            return "UIStackViewAlignmentFill"
        case .leading:
            return "UIStackViewAlignmentLeading"
        case .top:
            return "UIStackViewAlignmentTop"
        case .firstBaseline:
            return "UIStackViewAlignmentFirstBaseline"
        case .center:
            return "UIStackViewAlignmentCenter"
        case .trailing:
            return "UIStackViewAlignmentTrailing"
        case .bottom:
            return "UIStackViewAlignmentBottom"
        case .lastBaseline:
            return "UIStackViewAlignmentLastBaseline"
        }
    }
    
}

enum DistributionType: String {
    case fill
    case fillEqually
    case fillProportionally
    case equalSpacing
    case equalCentering
    
    var string: String {
        switch self {
        case .fill:
            return "UIStackViewDistributionFill"
        case .fillEqually:
            return "UIStackViewDistributionFillEqually"
        case .fillProportionally:
            return "UIStackViewDistributionFillProportionally"
        case .equalSpacing:
            return "UIStackViewDistributionEqualSpacing"
        case .equalCentering:
            return "UIStackViewDistributionEqualCentering"
        }
    }
}

// UIImage
enum ContentModeTpye: String {
    case scaleToFill
    case scaleAspectFit
    case scaleAspectFill
    
    case redraw
    case center
    
    case top
    case bottom
    case left
    case right
    
    case TopLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    
    var string: String {
        switch self {
        case .scaleToFill:
            return "UIViewContentModeScaleToFill"
        case .scaleAspectFit:
            return "UIViewContentModeScaleAspectFit"
        case .scaleAspectFill:
            return "UIViewContentModeScaleAspectFill"
        
        case .redraw:
            return "UIViewContentModeRedraw"
        case .center:
            return "UIViewContentModeCenter"
            
        case .top:
            return "UIViewContentModeTop"
        case .bottom:
            return "UIViewContentModeBottom"
        case .left:
            return "UIViewContentModeLeft"
        case .right:
            return "UIViewContentModeRight"
            
        case .TopLeft:
            return "UIViewContentModeTopLeft"
        case .topRight:
            return "UIViewContentModeTopRight"
        case .bottomLeft:
            return "UIViewContentModeBottomLeft"
        case .bottomRight:
            return "UIViewContentModeBottomRight"
        }
    }
    
}
