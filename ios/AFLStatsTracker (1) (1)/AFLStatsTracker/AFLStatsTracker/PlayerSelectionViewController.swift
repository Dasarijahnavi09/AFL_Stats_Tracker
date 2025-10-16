
//  PlayerSelectionViewController.swift
//  AFLStatsTracker
//
//  Created by Jahnavi Dasari on 8/5/2025.
//
import Firebase
import FirebaseFirestore
import UIKit

class PlayerSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var team1label: UILabel!
    @IBOutlet var team2label: UILabel!
    @IBOutlet weak var team1TableView: UITableView!
    @IBOutlet weak var team2TableView: UITableView!
    @IBOutlet var StartMatchButton: UIButton!
    
    var players: [Player] = []
    var team1Players: [Player] = []
    var team2Players: [Player] = []
    var team1Name: String?
    var team2Name: String?
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
        team1TableView.isScrollEnabled = true
        team2TableView.isScrollEnabled = true

            StartMatchButton.isEnabled = false
            team1label.text = team1Name ?? "Team 1"
            team2label.text = team2Name ?? "Team 2"

            team1TableView.delegate = self
            team1TableView.dataSource = self
            team2TableView.delegate = self
            team2TableView.dataSource = self

            team1TableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")
            team2TableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")

            team1TableView.setEditing(true, animated: false)
            team2TableView.setEditing(true, animated: false)
        }

        func updateStartButtonState() {
            StartMatchButton.isEnabled = team1Players.count >= 2 && team2Players.count >= 2
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tableView == team1TableView ? team1Players.count : team2Players.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
            let player = tableView == team1TableView ? team1Players[indexPath.row] : team2Players[indexPath.row]
            cell.textLabel?.text = "\(player.number) - \(player.name) (\(player.position))"
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .left
            return cell
        }

        // MARK: - Delete Only
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                guard let self = self else { return }
                if tableView == self.team1TableView {
                    self.team1Players.remove(at: indexPath.row)
                    self.team1TableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    self.team2Players.remove(at: indexPath.row)
                    self.team2TableView.deleteRows(at: [indexPath], with: .automatic)
                }
                self.updateStartButtonState()
                completion(true)
            }

            return UISwipeActionsConfiguration(actions: [deleteAction])
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "addPlayerToTeam1" {
                if let destVC = segue.destination as? AddPlayerViewController {
                    destVC.onSave = { [weak self] player in
                        self?.team1Players.append(player)
                        self?.team1TableView.reloadData()
                        self?.updateStartButtonState()
                    }
                }
            } else if segue.identifier == "addPlayerToTeam2" {
                if let destVC = segue.destination as? AddPlayerViewController {
                    destVC.onSave = { [weak self] player in
                        self?.team2Players.append(player)
                        self?.team2TableView.reloadData()
                        self?.updateStartButtonState()
                    }
                }
            } else if segue.identifier == "goToMatchRecording" {
                if let destVC = segue.destination as? MatchRecordingViewController {
                    destVC.team1Players = self.team1Players
                    destVC.team2Players = self.team2Players
                    destVC.team1Name = self.team1Name
                    destVC.team2Name = self.team2Name
                }
            }
        }
    
    }
