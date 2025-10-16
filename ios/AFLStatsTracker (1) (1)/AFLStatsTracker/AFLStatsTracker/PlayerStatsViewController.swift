import UIKit
import FirebaseFirestore

class PlayerStatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playerStatsTableView: UITableView!
    var matchId: String?

    struct PlayerStats {
        var name: String, team: String
        var goals, behinds, kicks, handballs, marks, tackles: Int
    }

    var allStats: [PlayerStats] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        playerStatsTableView.isScrollEnabled = true
        playerStatsTableView.delegate = self
        playerStatsTableView.dataSource = self
        fetchPlayerStats()
    }

    func fetchPlayerStats() {
        guard let matchId = matchId else { return }
        let db = Firestore.firestore()
        db.collection("matches").document(matchId).collection("playerStats").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.allStats = docs.map {
                    let d = $0.data()
                    return PlayerStats(
                        name: d["name"] as? String ?? "Unknown",
                        team: d["team"] as? String ?? "",
                        goals: d["goals"] as? Int ?? 0,
                        behinds: d["behinds"] as? Int ?? 0,
                        kicks: d["kicks"] as? Int ?? 0,
                        handballs: d["handballs"] as? Int ?? 0,
                        marks: d["marks"] as? Int ?? 0,
                        tackles: d["tackles"] as? Int ?? 0
                    )
                }
                DispatchQueue.main.async {
                    self.playerStatsTableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stat = allStats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerStatsCell", for: indexPath)
        cell.textLabel?.text = "\(stat.team) - \(stat.name)\nGoals: \(stat.goals), Behinds: \(stat.behinds), Kicks: \(stat.kicks), Handballs: \(stat.handballs), Marks: \(stat.marks), Tackles: \(stat.tackles)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    @IBAction func comparePlayerTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToComparePlayers", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlayerStats",
           let destination = segue.destination as? PlayerStatsViewController {
            destination.matchId = self.matchId
        } else if segue.identifier == "goToComparePlayers",
                  let destination = segue.destination as? ComparePlayersViewController {
            destination.matchId = self.matchId
        }
    }

}


