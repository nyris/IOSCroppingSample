//
//  CropOverlay.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Modified by Anas Mostefaoui on 2018.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal class CropOverlay: UIView {
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var tabbarHeight:CGFloat = 0.0
    var isSelected:Bool = false {
        didSet {
            
            self.centerButton?.isHidden = isSelected ? true : false
            self.isMovable = isSelected ? true : false
            self.isResizable = isSelected ? true : false
            
            _ = verticalLines.map {
                $0.isHidden = isSelected ? false : true
            }
            
            _ = outerLines.map {
                $0.isHidden = isSelected ? false : true
            }

            _ = topLeftCornerLines.map {
                $0.isHidden = isSelected ? false : true
            }
            
            _ = topRightCornerLines.map {
                $0.isHidden = isSelected ? false : true
            }
            
            _ = bottomLeftCornerLines.map {
                $0.isHidden = isSelected ? false : true
            }
            
            _ = bottomRightCornerLines.map {
                $0.isHidden = isSelected ? false : true
            }
            
            _ = horizontalLines.map {
                $0.isHidden = isSelected ? false : true
            }
            _ = cornerButtons.map {
                $0.isHidden = isSelected ? false : true
            }
        }
    }
    var outerLines = [UIView]()
    var horizontalLines = [UIView]()
    var verticalLines = [UIView]()
    
    var topLeftCornerLines = [UIView]()
    var topRightCornerLines = [UIView]()
    var bottomLeftCornerLines = [UIView]()
    var bottomRightCornerLines = [UIView]()
    
    var cornerButtons = [UIButton]()
    var centerButton:UIButton?
    
    let cornerLineDepth: CGFloat = 3
    let cornerLineWidth: CGFloat = 22.5
    var cornerButtonWidth: CGFloat {
        return self.cornerLineWidth * 2
    }
    
    let lineWidth: CGFloat = 1
    
    let outterGapRatio: CGFloat = 1/3
    var outterGap: CGFloat = 0
    
    var isResizable: Bool = false
    var isMovable: Bool = false
    var minimumSize: CGSize = CGSize.zero
    
    var selectionLock:Bool = false
    var onSelected:(_ crop:CropOverlay) -> Void = {_ in }
    var onUnSelected:(_ crop:CropOverlay) -> Void = {_ in }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        createLines()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createLines()
    }
    
    func generateLineFrame() {
        for i in 0..<outerLines.count {
            let line = outerLines[i]
            var lineFrame: CGRect
            switch (i) {
            case 0:
                lineFrame = CGRect(x: outterGap, y: outterGap, width: bounds.width - outterGap * 2, height: lineWidth)
            case 1:
                lineFrame = CGRect(x: bounds.width - lineWidth - outterGap, y: outterGap, width: lineWidth, height: bounds.height - outterGap * 2)
            case 2:
                lineFrame = CGRect(x: outterGap, y: bounds.height - lineWidth - outterGap, width: bounds.width - outterGap * 2, height: lineWidth)
            case 3:
                lineFrame = CGRect(x: outterGap, y: outterGap, width: lineWidth, height: bounds.height - outterGap * 2)
            default:
                lineFrame = CGRect.zero
            }
            
            line.frame = lineFrame
        }
    }
    
    func generateCorners() {
        let corners = [topLeftCornerLines, topRightCornerLines, bottomLeftCornerLines, bottomRightCornerLines]
        let buttonSize = CGSize(width: cornerButtonWidth, height: cornerButtonWidth)
        
        for i in 0..<corners.count {
            let corner = corners[i]
            
            var horizontalFrame: CGRect
            var verticalFrame: CGRect
            var buttonFrame: CGRect
            
            switch (i) {
            case 0:    // Top Left
                verticalFrame = CGRect(x: outterGap, y: outterGap, width: cornerLineDepth, height: cornerLineWidth)
                horizontalFrame = CGRect(x: outterGap, y: outterGap, width: cornerLineWidth, height: cornerLineDepth)
                buttonFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: buttonSize)
            case 1:    // Top Right
                verticalFrame = CGRect(x: bounds.width - cornerLineDepth - outterGap, y: outterGap, width: cornerLineDepth, height: cornerLineWidth)
                horizontalFrame = CGRect(x: bounds.width - cornerLineWidth - outterGap, y: outterGap, width: cornerLineWidth, height: cornerLineDepth)
                buttonFrame = CGRect(origin: CGPoint(x: bounds.width - cornerButtonWidth, y: 0), size: buttonSize)
            case 2:    // Bottom Left
                verticalFrame = CGRect(x: outterGap, y:  bounds.height - cornerLineWidth - outterGap, width: cornerLineDepth, height: cornerLineWidth)
                horizontalFrame = CGRect(x: outterGap, y:  bounds.height - cornerLineDepth - outterGap, width: cornerLineWidth, height: cornerLineDepth)
                buttonFrame = CGRect(origin: CGPoint(x: 0, y: bounds.height - cornerButtonWidth), size: buttonSize)
            case 3:    // Bottom Right
                verticalFrame = CGRect(
                    x: bounds.width - cornerLineDepth - outterGap,
                    y: bounds.height - cornerLineWidth - outterGap,
                    width: cornerLineDepth,
                    height: cornerLineWidth)
                horizontalFrame = CGRect(
                    x: bounds.width - cornerLineWidth - outterGap,
                    y: bounds.height - cornerLineDepth - outterGap,
                    width: cornerLineWidth,
                    height: cornerLineDepth)
                buttonFrame = CGRect(origin: CGPoint(x: bounds.width - cornerButtonWidth, y: bounds.height - cornerButtonWidth), size: buttonSize)
                
            default:
                verticalFrame = CGRect.zero
                horizontalFrame = CGRect.zero
                buttonFrame = CGRect.zero
            }
            
            corner[0].frame = verticalFrame
            corner[1].frame = horizontalFrame
            cornerButtons[i].frame = buttonFrame
        }
    }
    
    func generateCentralButton() {
        
        let widthCenter = self.frame.width / 2
        let heightCenter = self.frame.height / 2
        let height:CGFloat = 20.0
        let width:CGFloat = 20.0
        let x = widthCenter - (width / 2)
        let y = heightCenter - (height / 2)
        
        let buttonFrame = CGRect(x: x, y: y, width: width, height: height)
        if centerButton == nil {
            centerButton = UIButton()
            centerButton?.setImage(#imageLiteral(resourceName: "point_icon"), for: .normal)
            centerButton?.clipsToBounds = true
            centerButton?.imageView?.contentMode = .scaleAspectFit
            centerButton?.frame = buttonFrame
            addSubview(centerButton!)
        } else {
            centerButton?.frame = buttonFrame
        }
    }
    
    override func layoutSubviews() {
        
        self.generateLineFrame()
        self.generateCorners()
        self.generateCentralButton()
        
        let lineThickness = lineWidth / UIScreen.main.scale
        let vPadding = (bounds.height - outterGap * 2 - (lineThickness * CGFloat(horizontalLines.count))) / CGFloat(horizontalLines.count + 1)
        let hPadding = (bounds.width - outterGap * 2 - (lineThickness * CGFloat(verticalLines.count))) / CGFloat(verticalLines.count + 1)
        
        for i in 0..<horizontalLines.count {
            let hLine = horizontalLines[i]
            let vLine = verticalLines[i]
            
            let vSpacing = (vPadding * CGFloat(i + 1)) + (lineThickness * CGFloat(i))
            let hSpacing = (hPadding * CGFloat(i + 1)) + (lineThickness * CGFloat(i))
            
            hLine.frame = CGRect(x: outterGap, y: vSpacing + outterGap, width: bounds.width - outterGap * 2, height:  lineThickness)
            vLine.frame = CGRect(x: hSpacing + outterGap, y: outterGap, width: lineThickness, height: bounds.height - outterGap * 2)
        }
        
    }
    
    func createLines() {
        
        outerLines = [createLine(), createLine(), createLine(), createLine()]
//        horizontalLines = [createLine(), createLine()]
//        verticalLines = [createLine(), createLine()]
        
        topLeftCornerLines = [createLine(), createLine()]
        topRightCornerLines = [createLine(), createLine()]
        bottomLeftCornerLines = [createLine(), createLine()]
        bottomRightCornerLines = [createLine(), createLine()]
        
        cornerButtons = [createButton(), createButton(), createButton(), createButton()]
        
        let dragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveCropOverlay))
        addGestureRecognizer(dragGestureRecognizer)
    }
    
    func createLine(color:UIColor? = nil) -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor.white
        addSubview(line)
        if let color = color {
            line.backgroundColor = color
        }
        return line
    }
    
    func createButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        
        let dragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveCropOverlay))
        button.addGestureRecognizer(dragGestureRecognizer)
        
        addSubview(button)
        return button
    }
    
    @objc func moveCropOverlay(gestureRecognizer: UIPanGestureRecognizer) {
        if isResizable, let button = gestureRecognizer.view as? UIButton {
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let translation = gestureRecognizer.translation(in: self)
                
                var newFrame: CGRect
                
                switch button {
                case cornerButtons[0]:    // Top Left
                    newFrame = CGRect(x: frame.origin.x + translation.x,
                                      y: frame.origin.y + translation.y,
                                      width: frame.size.width - translation.x,
                                      height: frame.size.height - translation.y)
                case cornerButtons[1]:    // Top Right
                    newFrame = CGRect(x: frame.origin.x,
                                      y: frame.origin.y + translation.y,
                                      width: frame.size.width + translation.x,
                                      height: frame.size.height - translation.y)
                case cornerButtons[2]:    // Bottom Left
                    newFrame = CGRect(x: frame.origin.x + translation.x,
                                      y: frame.origin.y,
                                      width: frame.size.width - translation.x,
                                      height: frame.size.height + translation.y)
                case cornerButtons[3]:    // Bottom Right
                    newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width + translation.x, height: frame.size.height + translation.y)
                default:
                    newFrame = CGRect.zero
                }
                
                let minimumFrame = CGRect(x: newFrame.origin.x,
                                          y: newFrame.origin.y,
                                          width: max(newFrame.size.width, minimumSize.width + 2 * outterGap),
                                          height: max(newFrame.size.height, minimumSize.height + 2 * outterGap))
                frame = minimumFrame
                layoutSubviews()
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
            }
        } else if isMovable {
            self.move(gestureRecognizer: gestureRecognizer)
        }
    }
    
    func move(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self)
            
            var xMovement = gestureRecognizer.view!.center.x + translation.x
            var yMovement = gestureRecognizer.view!.center.y + translation.y
            
            xMovement = canMoveHorizontaly(xMovement: xMovement) ? xMovement : gestureRecognizer.view!.center.x - translation.x
            yMovement = canMoveVerticaly(yMovement: yMovement) ? yMovement : gestureRecognizer.view!.center.y - translation.y
            
            gestureRecognizer.view!.center = CGPoint(
                x: xMovement,
                y: yMovement)
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
        }
    }

    private func canMoveHorizontaly(xMovement:CGFloat) -> Bool {
        let width = self.frame.size.width - (2 * outterGap)
        return xMovement - ( width * 0.5 ) >= 0 && // should stop at left bound
        xMovement + ( width * 0.5)  <= screenWidth
    }
    
    private func canMoveVerticaly(yMovement:CGFloat) -> Bool {
        let height = self.frame.size.height - (2 * outterGap)
        return yMovement - (height * 0.5) >= 0 && // should stop at the top bound
        yMovement + (height * 0.5)  <= (screenHeight - tabbarHeight) // should bottom at the top boun
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view == nil {
            if selectionLock == false || isSelected == true {
                self.onUnSelected(self)
                self.isSelected = false // taped out of the view
            }
            selectionLock = true
        } else {
            if isSelected == false && view != nil {
                self.onSelected(self)
                isSelected = true
            }
        }
        
        if !isMovable && isResizable && view != nil {
            let isButton = cornerButtons.reduce(false) { $1.hitTest(convert(point, to: $1), with: event) != nil || $0 }
            if !isButton {
                return nil
            }
        }
        
        return view
    }
}
