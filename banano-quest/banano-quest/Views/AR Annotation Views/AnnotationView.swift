//
//  AnnotationView.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 7/24/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import SceneKit

protocol AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView)
}

class AnnotationView: ARAnnotationView {
    
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var sceneView: SCNView?
    var submitButton: UIButton?
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        loadUI()
    }
    
    func loadUI() {
        // We remove all elements from the superview
        titleLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        sceneView?.removeFromSuperview()
        submitButton?.removeFromSuperview()
        
        // Title label
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
        
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        label.textColor = UIColor.yellow
        
        self.addSubview(label)
        self.titleLabel = label
        
        // Distance label
        let label2 = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20))
        
        label2.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        label2.textColor = UIColor.green
        label2.font = UIFont.systemFont(ofSize: 12)
        
        self.addSubview(label2)
        self.distanceLabel = label2
        
        // Annotation setup
        if let annotation = annotation {
            // Quest Info
            titleLabel?.text = annotation.title
            distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)
            
            // Scene for 3d object
            let myView = SCNView(frame: CGRect(x: 10, y: 45, width: 180, height: 180), options: nil)
            
            let materialA = SCNMaterial()
            materialA.diffuse.contents = UIImage(named: "cascara.png")
            
            let materialB = SCNMaterial()
            materialB.normal.contents = UIImage(named: "cascaranormal.png")
            
            myView.scene = SCNScene.init(named: "banano.scn")
            myView.scene?.rootNode.geometry?.materials = [materialA, materialB]
            
            myView.allowsCameraControl = true
            myView.autoenablesDefaultLighting = true
            myView.backgroundColor = UIColor.clear
            
            self.addSubview(myView)
            sceneView = myView
            
            // Submit button
            let button = UIButton(frame: CGRect(x: 0, y: self.frame.height + 10, width: self.frame.width, height: 35))
            
            button.setTitle("Submit", for: .normal)
            button.layer.cornerRadius = 10
            button.addTarget(self, action: #selector(self.pressButton(_:)), for: .touchUpInside)
            button.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.55)
            
            self.addSubview(button)
            submitButton = button
        }
    }
    
    @objc func pressButton(_ sender: UIButton){
        print("\(sender)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30)
        distanceLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20)
        sceneView?.frame = CGRect(x: 10, y: 45, width: 180, height: 180)
        submitButton?.frame = CGRect(x: 0, y: self.frame.height + 10, width: self.frame.width, height: 35)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
}
