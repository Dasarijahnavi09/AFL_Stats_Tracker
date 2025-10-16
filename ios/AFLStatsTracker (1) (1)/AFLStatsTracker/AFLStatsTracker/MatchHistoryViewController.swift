import UIKit
import FirebaseFirestore

class MatchHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var matches: [(id: String, team1: String, team2: String, score1: String, score2: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        fetchMatches()
    }

    func fetchMatches() {
        let db = Firestore.firestore()
        db.collection("matches").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else {
                print("Error fetching matches: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            self.matches = docs.compactMap { doc in
                let data = doc.data()
                let id = doc.documentID
                let team1 = data["team1Name"] as? String ?? "Team 1"
                let team2 = data["team2Name"] as? String ?? "Team 2"
                let score1 = data["team1Score"] as? String ?? "0.0 (0)"
                let score2 = data["team2Score"] as? String ?? "0.0 (0)"
                return (id, team1, team2, score1, score2)
            }
            self.tableView.reloadData()
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = matches[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath)
        cell.textLabel?.text = "\(match.team1) \(match.score1) vs \(match.team2) \(match.score2)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let matchId = matches[indexPath.row].id
        performSegue(withIdentifier: "goToSummaryFromHistory", sender: matchId)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSummaryFromHistory",
           let destination = segue.destination as? MatchSummaryViewController,
           let matchId = sender as? String {
            destination.matchId = matchId
        }
    }
}
