//
//  GameViewController.swift
//  Lock On
//
//  Created by JavaJunky on 12/11/2018.
//  Copyright © 2018 RS IT Solutions and Design Ltd. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate, ARSessionDelegate {
    
    

    var itemsArray : [String] = ["Armouries"]
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    private var hud : MBProgressHUD!
    private var armouryNode : SCNNode!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.session.delegate = self
        self.sceneView.delegate = self
        self.sceneView.automaticallyUpdatesLighting = true
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.itemsCollectionView.dataSource = self
        self.itemsCollectionView.delegate = self
        self.configuration.planeDetection = .horizontal
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.label.text = "Detecting Surfaces"
        self.sceneView.session.run(configuration)

        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell
        cell.itemLabel.text = self.itemsArray[indexPath.row]
        return cell
    }

    // MARK: - Gesture recognizer
    private func addRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    // MARK: - tap functions
    @objc private func tapped(recogizer: UITapGestureRecognizer) {
        let sceneView = recogizer.view as! ARSCNView
        let tapLocation = recogizer.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            self.addArmoury(hitTestResult: hitTest.first!)
        } else {
            print("No planes detected")
        }
        
        
    }
    
    // MARK: - Add Armoury
    private func addArmoury(hitTestResult: ARHitTestResult) {
        let armouryScene = SCNScene(named: "Armouries.scnassets/Armouries.scn")
        armouryNode = armouryScene?.rootNode.childNode(withName: "Armoury", recursively: true)
        let transform = hitTestResult.worldTransform
        let planeXPosition = transform.columns.3.x
        let planeYPosition = transform.columns.3.y
        //let planeZPosition = transform.columns.3.z
        armouryNode?.position = SCNVector3(planeXPosition,planeYPosition,-2)
        self.sceneView.scene.rootNode.addChildNode(armouryNode!)
        // MARK: - Add Weapons to Armoury
        self.addGrenadeToArmoury()
        self.addMissileToArmoury()
        self.addBulletsToArmoury()
        
    }
    
    //MARK: - addGrenade to Armoury
    private func addGrenadeToArmoury() {
        // add a child node grenade to the armoury
        let grenadeScene = SCNScene(named: "Armouries.scnassets/bbgren.scn")
        let grenadeNode = grenadeScene?.rootNode.childNode(withName: "Grenade", recursively: true)
        grenadeNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        // get the parent node from the armoury
        
        let grenadeParent = armouryNode.childNode(withName: "Grenade", recursively: true)
        grenadeParent?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        grenadeParent?.addChildNode(grenadeNode!)
        
    }
    
    //MARK: - add bullets to armoury
    private func addBulletsToArmoury() {
        let bulletScene = SCNScene(named: "Armouries.scnassets/Bullets.scn")
        let bulletNode = bulletScene?.rootNode.childNode(withName: "Bullet", recursively: true)
        bulletNode?.scale = SCNVector3(0.05, 0.05, 0.05)
        let bulletParent = armouryNode.childNode(withName: "Bullets", recursively: true)
        bulletParent?.addChildNode(bulletNode!)
    }
    // MARK: - Add missile to Armoury
    private func addMissileToArmoury() {
        let missileScene = SCNScene(named: "Armouries.scnassets/missile.scn")
        let missileNode = missileScene?.rootNode.childNode(withName: "MissileNode", recursively: true)
        missileNode?.scale = SCNVector3(0.1, 0.1, 0.1)
        let missileParent = armouryNode.childNode(withName: "Missile", recursively: true)
        missileParent?.addChildNode(missileNode!)
    }
    // MARK: - DidAddNode
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("plane is detected")
            DispatchQueue.main.async {
                self.hud.label.text = "Surface Detected"
                self.hud.hide(animated: true, afterDelay: 2)
                self.addRecognizers()
                
            }
            return
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable:
            //print("Not Available")
            break
        case .limited:
            //print("Limited")
            break
        case .extending:
            //print("EXTENDING")
            break
        case .mapped:
            //print("Mapped")
            //self.saveWorldMapButton.isHidden = false
            break
        }
    }
}
