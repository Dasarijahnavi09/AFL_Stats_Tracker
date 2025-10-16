//
//  TeamSelectionViewController.swift
//  AFLStatsTracker
//
//  Created by Jahnavi Dasari on 7/5/2025.
//
import Firebase
import FirebaseFirestore
import UIKit

class TeamSelectionViewController: UIViewController {

    @IBOutlet var enterteam2: UITextField!
    @IBOutlet var enterteam1: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func team1name(_ sender: Any) {
    }
    
    @IBAction func team2name(_ sender: Any) {
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlayerSelection" {
            if let destVC = segue.destination as? PlayerSelectionViewController {
                destVC.team1Name = enterteam1.text
                destVC.team2Name = enterteam2.text
            }
        }
    }
    
    @IBAction func Continue(_ sender: Any) {
        print("Continue tapped")
        self.performSegue(withIdentifier: "goToPlayerSelection", sender: self)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
