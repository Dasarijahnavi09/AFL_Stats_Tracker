import UIKit
import FirebaseFirestore

class MatchSummaryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var team1NameLabel: UILabel!
    @IBOutlet weak var team2NameLabel: UILabel!
    @IBOutlet weak var team1TotalLabel: UILabel!
    @IBOutlet weak var team2TotalLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var playerOfMatchLabel: UILabel!
    
    // MARK: - Properties
    var matchId: String?
    private var quarters = [Quarter]()
    private var matchDetails: MatchDetails?
    private var team1Stats: [String: PlayerStats] = [:]
    private var team2Stats: [String: PlayerStats] = [:]
    
    // MARK: - Models
    struct Quarter {
        let number: Int
        let team1Score: String
        let team2Score: String
    }

    struct MatchDetails {
        let team1Name: String
        let team2Name: String
        let team1Total: String
        let team2Total: String
    }

    struct PlayerStats {
        var kicks = 0, handballs = 0, goals = 0, behinds = 0, tackles = 0, marks = 0
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isScrollEnabled = true
        configureCollectionView()
        loadAllData()
        
        
    }

    // MARK: - Collection Setup
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // MARK: - Firestore Fetch
    private func loadAllData() {
        guard let matchId = matchId else {
                    print("Match ID is nil")
                    return
                }
        
        let db = Firestore.firestore()
        let matchRef = db.collection("matches").document(matchId)
        
        matchRef.getDocument { snapshot, error in
                    guard let data = snapshot?.data(), error == nil else {
                        print("Error fetching match data: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

            self.matchDetails = MatchDetails(
                team1Name: data["team1Name"] as? String ?? "Team 1",
                team2Name: data["team2Name"] as? String ?? "Team 2",
                team1Total: data["team1Score"] as? String ?? "0.0 (0)",
                team2Total: data["team2Score"] as? String ?? "0.0 (0)"
            )
            self.updateHeaderUI()
            self.fetchPlayerStats(matchRef: matchRef)
        }
    }
    private func fetchPlayerStats(matchRef: DocumentReference) {
            matchRef.collection("playerStats").getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    print("Error fetching player stats: \(error?.localizedDescription ?? "Unknown")")
                    self.loadQuarters(matchRef: matchRef)
                    return
                }

                for doc in docs {
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let team = data["team"] as? String else { continue }

                    let stats = PlayerStats(
                        kicks: data["kicks"] as? Int ?? 0,
                        handballs: data["handballs"] as? Int ?? 0,
                        goals: data["goals"] as? Int ?? 0,
                        behinds: data["behinds"] as? Int ?? 0,
                        tackles: data["tackles"] as? Int ?? 0,
                        marks: data["marks"] as? Int ?? 0
                    )

                    if team == self.matchDetails?.team1Name {
                        self.team1Stats[name] = stats
                    } else if team == self.matchDetails?.team2Name {
                        self.team2Stats[name] = stats
                    }
                }

                self.updateWinnerAndPlayerOfMatch()
                self.loadQuarters(matchRef: matchRef)
            }
        }

    private func loadQuarters(matchRef: DocumentReference) {
            matchRef.collection("quarters").order(by: FieldPath.documentID()).getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    print("Error loading quarters: \(error?.localizedDescription ?? "Unknown")")
                    return
                }

                self.quarters = docs.compactMap { doc in
                    let data = doc.data()
                    guard let quarterNumber = Int(doc.documentID) else { return nil }

                    let team1Score = "\(data["team1Goals"] as? Int ?? 0).\(data["team1Behinds"] as? Int ?? 0)"
                    let team2Score = "\(data["team2Goals"] as? Int ?? 0).\(data["team2Behinds"] as? Int ?? 0)"

                    return Quarter(number: quarterNumber, team1Score: team1Score, team2Score: team2Score)
                }

                self.collectionView.reloadData()
            }
        }

        // MARK: - UI Updates
        private func updateHeaderUI() {
            guard let details = matchDetails else { return }
            team1NameLabel.text = details.team1Name
            team2NameLabel.text = details.team2Name
            team1TotalLabel.text = details.team1Total
            team2TotalLabel.text = details.team2Total
        }

        private func updateWinnerAndPlayerOfMatch() {
            guard let team1Total = extractTotalScore(from: matchDetails?.team1Total ?? "0.0 (0)"),
                  let team2Total = extractTotalScore(from: matchDetails?.team2Total ?? "0.0 (0)") else { return }

            if team1Total > team2Total {
                winnerLabel.text = "🏆 Winner: \(matchDetails?.team1Name ?? "Team 1")"
            } else if team2Total > team1Total {
                winnerLabel.text = "🏆 Winner: \(matchDetails?.team2Name ?? "Team 2")"
            } else {
                winnerLabel.text = "🏆 Draw"
            }

            playerOfMatchLabel.text = "⭐ Player of the Match:\(getPlayerOfTheMatch())"
        }

        private func extractTotalScore(from score: String) -> Int? {
            guard let start = score.firstIndex(of: "("),
                  let end = score.firstIndex(of: ")") else { return nil }
            let totalString = score[score.index(after: start)..<end]
            return Int(totalString)
        }

        private func getPlayerOfTheMatch() -> String {
            var bestScore = -1
            var bestPlayer = "N/A"
            var team = ""

            for (name, stats) in team1Stats {
                let score = stats.kicks + stats.handballs + stats.goals + stats.behinds + stats.tackles + stats.marks
                if score > bestScore {
                    bestScore = score
                    bestPlayer = name
                    team = matchDetails?.team1Name ?? "Team 1"
                }
            }

            for (name, stats) in team2Stats {
                let score = stats.kicks + stats.handballs + stats.goals + stats.behinds + stats.tackles + stats.marks
                if score > bestScore {
                    bestScore = score
                    bestPlayer = name
                    team = matchDetails?.team2Name ?? "Team 2"
                }
            }

            return "\(bestPlayer) (\(team), Points: \(bestScore))"
        }

        // MARK: - CollectionView
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return quarters.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuarterCell", for: indexPath) as! QuarterCell
            let quarter = quarters[indexPath.item]
            cell.configure(quarter: quarter.number, team1Score: quarter.team1Score, team2Score: quarter.team2Score)
            return cell
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.bounds.width - 40, height: 100)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }

    // MARK: - Navigation
    @IBAction func shareSummaryTapped(_ sender: UIButton) {
        guard let details = matchDetails else { return }

               let summary = """
               AFL Match Summary

               \(details.team1Name) vs \(details.team2Name)

               Final Score:
               \(details.team1Name): \(details.team1Total)
               \(details.team2Name): \(details.team2Total)

               \(winnerLabel.text ?? "")
               \(playerOfMatchLabel.text ?? "")
               """

               let activityVC = UIActivityViewController(activityItems: [summary], applicationActivities: nil)
               present(activityVC, animated: true)
    }
    
    @IBAction func playerStatsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPlayerStats", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlayerStats",
           let destination = segue.destination as? PlayerStatsViewController {
            destination.matchId = self.matchId
        }
    }
    
}



