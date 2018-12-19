//
//  ViewController.swift
//  Lock On
//
//  Created by JavaJunky on 12/11/2018.
//  Copyright © 2018 RS IT Solutions and Design Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var NewGame: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func startGame(_ sender: Any) {
        self.performSegue(withIdentifier: "GameSegue", sender: self)
    }
    
}

