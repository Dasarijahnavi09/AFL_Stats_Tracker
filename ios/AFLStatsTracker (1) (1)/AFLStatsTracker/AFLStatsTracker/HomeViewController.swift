//
//  ViewController.swift
//  AFLStatsTracker
//
//  Created by Jahnavi Dasari on 7/5/2025.
//
import Firebase
import FirebaseFirestore
import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func creatematchclicked(_ sender: Any) {
        print("Create Match button tapped")
        self.performSegue(withIdentifier: "goToTeamSelection", sender: self)   
    }
    
    @IBAction func matchhistoryclicked(_ sender: Any) {
        print("Match History button tapped")
        self.performSegue(withIdentifier: "goToMatchHistory", sender: self)
    }
}
