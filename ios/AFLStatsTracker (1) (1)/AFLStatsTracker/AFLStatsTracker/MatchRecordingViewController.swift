import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit

class MatchRecordingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet var playerTableView: UITableView!
    @IBOutlet var teamLabel: UILabel!
    @IBOutlet var quarterLabel: UILabel!
    @IBOutlet var scoreLabelTeam1: UILabel!
    @IBOutlet var scoreLabelTeam2: UILabel!
    
    @IBOutlet var endQuarterButton: UIButton!
    var team1Name: String?
    var team2Name: String?
    var currentQuarter = 1
    var lastAction: String?
    
    // MARK: - Models
    struct PlayerStats {
        var kicks = 0, handballs = 0, goals = 0, behinds = 0, tackles = 0, marks = 0
        
    }
    
    struct MatchAction {
        var timestamp: Date
        var playerName: String
        var team: String
        var action: String
    }
    
    // MARK: - Variables
    var team1Players: [Player] = []
    var team2Players: [Player] = []
    var selectedIndexPath: IndexPath?
    
    var team1Stats: [String: PlayerStats] = [:]
    var team2Stats: [String: PlayerStats] = [:]
    var matchTimeline: [MatchAction] = []
    
    var selectedPlayer: String?
    var selectedTeam: String?
    
    var matchId: String?
    var currentMatchId: String?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let db = Firestore.firestore()
        matchId = db.collection("matches").document().documentID
        
        playerTableView.delegate = self
        playerTableView.dataSource = self
        playerTableView.isScrollEnabled = true
        teamLabel.text = "\(team1Name ?? "Team 1") vs \(team2Name ?? "Team 2")"
        quarterLabel.text = "Quarter \(currentQuarter)"
        scoreLabelTeam1.text = "0.0(0)"
        scoreLabelTeam2.text = "0.0(0)"
        
    }
    
    // MARK: - Actions
    func recordAction(_ action: String) {
        guard let player = selectedPlayer, let team = selectedTeam else {
            showAlert("Please select a player before recording an action.")
            selectedPlayer = nil
            selectedTeam = nil
            return
        }
        if (action == "Goal" || action == "Behind") && lastAction != "Kick" {
            showAlert("A Kick should be recorded before a \(action).")
            return
        }
        lastAction = action
        
        
        var stats = (team == "Team1" ? team1Stats[player] : team2Stats[player]) ?? PlayerStats()
        updateStats(&stats, with: action)
        
        if team == "Team1" {
            team1Stats[player] = stats
        } else {
            team2Stats[player] = stats
        }
        
        matchTimeline.append(MatchAction(timestamp: Date(), playerName: player, team: team, action: action))
        updateScores()
        let fullTeamName = team == "Team1" ? team1Name ?? "Team 1" : team2Name ?? "Team 2"
        print("✅ \(action) recorded for \(player) from \(fullTeamName)")
            print("Team1 Stats: \(team1Stats)")
            print("Team2 Stats: \(team2Stats)")
    }
    
    
    func updateStats(_ stats: inout PlayerStats, with action: String, reverse: Bool = false) {
        let delta = reverse ? -1 : 1
        switch action {
        case "Kick": stats.kicks += delta
        case "Handball": stats.handballs += delta
        case "Goal": stats.goals += delta
        case "Behind": stats.behinds += delta
        case "Tackle": stats.tackles += delta
        case "Mark": stats.marks += delta
        default: break
        }
    }
    
    func updateScores() {
        let team1Goals = team1Stats.values.reduce(0) { $0 + $1.goals }
        let team1Behinds = team1Stats.values.reduce(0) { $0 + $1.behinds }
        let team1Total = team1Goals * 6 + team1Behinds
        
        let team2Goals = team2Stats.values.reduce(0) { $0 + $1.goals }
        let team2Behinds = team2Stats.values.reduce(0) { $0 + $1.behinds }
        let team2Total = team2Goals * 6 + team2Behinds
        
        scoreLabelTeam1.text = "\(team1Goals).\(team1Behinds) (\(team1Total))"
        scoreLabelTeam2.text = "\(team2Goals).\(team2Behinds) (\(team2Total))"
    }
    
    
    func undoLastAction() {
        guard let last = matchTimeline.popLast() else { return }
        var stats = (last.team == "Team1" ? team1Stats[last.playerName] : team2Stats[last.playerName]) ?? PlayerStats()
        updateStats(&stats, with: last.action, reverse: true)
        if last.team == "Team1" {
            team1Stats[last.playerName] = stats
        } else {
            team2Stats[last.playerName] = stats
        }
        updateScores()
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func kickTapped(_ sender: UIButton) { recordAction("Kick") }
    @IBAction func handballTapped(_ sender: UIButton) { recordAction("Handball") }
    @IBAction func goalTapped(_ sender: UIButton) { recordAction("Goal") }
    @IBAction func tackleTapped(_ sender: UIButton) { recordAction("Tackle") }
    @IBAction func markTapped(_ sender: UIButton) { recordAction("Mark") }
    @IBAction func behindTapped(_ sender: UIButton) { recordAction("Behind") }
    @IBAction func undoTapped(_ sender: UIButton) { undoLastAction() }
    
    
    @IBAction func endquarterTapped(_ sender: UIButton) {
        
        guard currentQuarter <= 4 else { return }

            let db = Firestore.firestore()
            guard let matchId = matchId else {
                print("Error: matchId is nil")
                showAlert("Error: Match ID is missing.")
                return
            }
            let matchRef = db.collection("matches").document(matchId)
            currentMatchId = matchRef.documentID

            let team1Goals = team1Stats.values.reduce(0) { $0 + $1.goals }
            let team1Behinds = team1Stats.values.reduce(0) { $0 + $1.behinds }
            let team2Goals = team2Stats.values.reduce(0) { $0 + $1.goals }
            let team2Behinds = team2Stats.values.reduce(0) { $0 + $1.behinds }

            let quarterData: [String: Any] = [
                "team1Goals": team1Goals,
                "team1Behinds": team1Behinds,
                "team2Goals": team2Goals,
                "team2Behinds": team2Behinds
            ]

            print("📦 Saving quarter \(currentQuarter) data: \(quarterData)")
            matchRef.collection("quarters").document("\(currentQuarter)").setData(quarterData) { error in
                if let error = error {
                    print("Error saving Quarter \(self.currentQuarter): \(error)")
                } else {
                    print("✅ Quarter \(self.currentQuarter) saved successfully.")
                }
            }

            if currentQuarter < 4 {
                currentQuarter += 1
                quarterLabel.text = "Quarter \(currentQuarter)"
            } else {
                showAlert("Match complete. All 4 quarters done.")
                endQuarterButton.isEnabled = false  // 🔒 Disable after Q4
            }
        }
    // MARK: - Collection View
    
    
    @IBAction func endTapped(_ sender: UIButton) {
        guard let matchId = matchId else {
               showAlert("Match ID is missing.")
               return
           }

           let db = Firestore.firestore()
           let storage = Storage.storage()
           let matchRef = db.collection("matches").document(matchId)

           let team1Goals = team1Stats.values.reduce(0) { $0 + $1.goals }
           let team1Behinds = team1Stats.values.reduce(0) { $0 + $1.behinds }
           let team1Total = team1Goals * 6 + team1Behinds

           let team2Goals = team2Stats.values.reduce(0) { $0 + $1.goals }
           let team2Behinds = team2Stats.values.reduce(0) { $0 + $1.behinds }
           let team2Total = team2Goals * 6 + team2Behinds

           // ⏱ Save any remaining quarters (e.g., if user ends match early)
           for q in currentQuarter...4 {
               let quarterRef = matchRef.collection("quarters").document("\(q)")
               let quarterData: [String: Any] = [
                   "team1Goals": team1Goals,
                   "team1Behinds": team1Behinds,
                   "team2Goals": team2Goals,
                   "team2Behinds": team2Behinds
               ]
               print("📦 Auto-saving missing quarter \(q): \(quarterData)")
               quarterRef.setData(quarterData)
           }

           // 🔐 Disable end quarter button
           endQuarterButton?.isEnabled = false

           // 🏁 Save match details
           let match = Match(
               team1Name: team1Name ?? "Team 1",
               team2Name: team2Name ?? "Team 2",
               team1Score: "\(team1Goals).\(team1Behinds) (\(team1Total))",
               team2Score: "\(team2Goals).\(team2Behinds) (\(team2Total))",
               quarter: 4,
               timestamp: Date()
           )

           do {
               try matchRef.setData(from: match) { error in
                   if let error = error {
                       print("Error saving match: \(error)")
                       return
                   }

                   let allPlayers = self.team1Players + self.team2Players
                   let totalPlayers = allPlayers.count
                   var savedPlayers = 0

                   for player in allPlayers {
                       let team = self.team1Players.contains(where: { $0.name == player.name }) ? self.team1Name ?? "Team 1" : self.team2Name ?? "Team 2"
                       let stats = team == self.team1Name ? self.team1Stats[player.name] ?? PlayerStats() : self.team2Stats[player.name] ?? PlayerStats()

                       let playerDoc = matchRef.collection("playerStats").document(player.name)
                       let data: [String: Any] = [
                           "name": player.name,
                           "team": team,
                           "goals": stats.goals,
                           "behinds": stats.behinds,
                           "kicks": stats.kicks,
                           "handballs": stats.handballs,
                           "marks": stats.marks,
                           "tackles": stats.tackles
                       ]
                       playerDoc.setData(data)

                       // Upload image
                       if let imageData = player.image?.jpegData(compressionQuality: 0.8) {
                           let imageRef = storage.reference().child("playerImages/\(player.name)_\(matchId).jpg")
                           imageRef.putData(imageData, metadata: nil) { _, error in
                               if let error = error {
                                   print("⚠️ Failed to upload image for \(player.name): \(error)")
                               } else {
                                   print("✅ Uploaded image for \(player.name)")
                               }

                               savedPlayers += 1
                               if savedPlayers == totalPlayers {
                                   self.proceedToSummary(matchId: matchId)
                               }
                           }
                       } else {
                           savedPlayers += 1
                           if savedPlayers == totalPlayers {
                               self.proceedToSummary(matchId: matchId)
                           }
                       }
                   }
               }
           } catch {
               print("Encoding error: \(error)")
           }
       }

            func proceedToSummary(matchId: String) {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToMatchSummary", sender: matchId)
                }
            }

            // MARK: - Table View
            func numberOfSections(in tableView: UITableView) -> Int {
                return 2
            }

            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return section == 0 ? team1Players.count : team2Players.count
            }

            func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
                return section == 0 ? team1Name : team2Name
            }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let player = indexPath.section == 0 ? team1Players[indexPath.row] : team2Players[indexPath.row]
        selectedPlayer = player.name
        selectedTeam = indexPath.section == 0 ? "Team1" : "Team2"
        tableView.reloadData()
        
        let teamName = indexPath.section == 0 ? team1Name ?? "Team 1" : team2Name ?? "Team 2"
        print("✅ Selected player: \(player.name) (#\(player.number)) from \(teamName)")
    }

            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as? PlayerTableViewCell else {
                    return UITableViewCell()
                }

                let player = indexPath.section == 0 ? team1Players[indexPath.row] : team2Players[indexPath.row]
                cell.playerLabel.text = "\(player.number) - \(player.name)"
                cell.playerImageView.image = player.image ?? UIImage(systemName: "person.circle")

                if indexPath == selectedIndexPath {
                    cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                } else {
                    cell.backgroundColor = .white
                }

                return cell
            }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

            override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "goToMatchSummary",
                   let destination = segue.destination as? MatchSummaryViewController,
                   let matchId = sender as? String {
                    destination.matchId = matchId
                }
            }
        }
