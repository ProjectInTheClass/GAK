//
//  GridView.swift
//  gaak
//
//  Created by 서인재 on 2020/10/15.
//  Copyright © 2020 Ted Kim. All rights reserved.
//  참고 소스: https://gist.github.com/khurram18/706f65035a32dbe6ad084d9d0e672d0f

import UIKit

class GridView: UIView {
    
    override func draw(_ rect: CGRect) {
        
        print("draw func has called")
        
        // Drawing code
        
        let borderLayer = gridLayer()
        borderLayer.path = UIBezierPath(rect: bounds).cgPath
        layer.addSublayer(borderLayer)
        
        let firstColumnPath = UIBezierPath()
        firstColumnPath.move(to: CGPoint(x: bounds.width / 3, y: 0))
        firstColumnPath.addLine(to: CGPoint(x: bounds.width / 3, y: bounds.height))
        let firstColumnLayer = gridLayer()
        firstColumnLayer.path = firstColumnPath.cgPath
        layer.addSublayer(firstColumnLayer)
        
        let secondColumnPath = UIBezierPath()
        secondColumnPath.move(to: CGPoint(x: (2 * bounds.width) / 3, y: 0))
        secondColumnPath.addLine(to: CGPoint(x: (2 * bounds.width) / 3, y: bounds.height))
        let secondColumnLayer = gridLayer()
        secondColumnLayer.path = secondColumnPath.cgPath
        layer.addSublayer(secondColumnLayer)
        
        let firstRowPath = UIBezierPath()
        firstRowPath.move(to: CGPoint(x: 0, y: bounds.height / 3))
        firstRowPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 3))
        let firstRowLayer = gridLayer()
        firstRowLayer.path = firstRowPath.cgPath
        layer.addSublayer(firstRowLayer)
        
        let secondRowPath = UIBezierPath()
        secondRowPath.move(to: CGPoint(x: 0, y: ( 2 * bounds.height) / 3))
        secondRowPath.addLine(to: CGPoint(x: bounds.width, y: ( 2 * bounds.height) / 3))
        let secondRowLayer = gridLayer()
        secondRowLayer.path = secondRowPath.cgPath
        layer.addSublayer(secondRowLayer)
    }
    
    func gridLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineDashPattern = [3, 3]
        shapeLayer.frame = bounds
//        shapeLayer.fillColor = UIColor.orange.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        // 클리어로 채우기 구현하지 않고, 스토리보드의 이미지 뷰의 투명도를 조절했습니다.
        return shapeLayer
    }
}

