import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ComparePlayersViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var player1Button: UIButton!
    @IBOutlet weak var player2Button: UIButton!
    @IBOutlet weak var player1StatsLabel: UILabel!
    @IBOutlet weak var player2StatsLabel: UILabel!
    
    @IBOutlet var bestPlayerLabel: UILabel!
    var matchId: String?
    private var allPlayers: [String: (UIImage?, PlayerStats)] = [:]
    var selectedStats1: PlayerStats?
    var selectedStats2: PlayerStats?
    var selectedName1: String?
    var selectedName2: String?


        struct PlayerStats {
            var goals = 0
            var behinds = 0
            var kicks = 0
            var handballs = 0
            var marks = 0
            var tackles = 0
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            bestPlayerLabel.text = ""
            fetchPlayerStats()
        }

        func fetchPlayerStats() {
            guard let matchId = matchId else { return }
            let db = Firestore.firestore()
            let storage = Storage.storage()
            let statsRef = db.collection("matches").document(matchId).collection("playerStats")

            statsRef.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching player stats: \(error?.localizedDescription ?? "Unknown")")
                    return
                }

                for doc in documents {
                    let data = doc.data()
                    let name = data["name"] as? String ?? "Unknown"
                    let stats = PlayerStats(
                        goals: data["goals"] as? Int ?? 0,
                        behinds: data["behinds"] as? Int ?? 0,
                        kicks: data["kicks"] as? Int ?? 0,
                        handballs: data["handballs"] as? Int ?? 0,
                        marks: data["marks"] as? Int ?? 0,
                        tackles: data["tackles"] as? Int ?? 0
                    )

                    let imagePath = "playerImages/\(name)_\(matchId).jpg"
                    let imageRef = storage.reference(withPath: imagePath)
                    imageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
                        let image = data != nil ? UIImage(data: data!) : UIImage(systemName: "person.circle")
                        self.allPlayers[name] = (image, stats)
                    }
                }
            }
        }

        func showPlayerPicker(isForPlayer1: Bool) {
            let alert = UIAlertController(title: "Select Player", message: nil, preferredStyle: .actionSheet)
            for (name, (image, stats)) in allPlayers {
                alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                    if isForPlayer1 {
                        guard let button = self.player1Button, let label = self.player1StatsLabel else { return }
                        self.updatePlayerUI(button: button, label: label, image: image, name: name, stats: stats)
                        self.selectedStats1 = stats
                        self.selectedName1 = name
                    } else {
                        guard let button = self.player2Button, let label = self.player2StatsLabel else { return }
                        self.updatePlayerUI(button: button, label: label, image: image, name: name, stats: stats)
                        self.selectedStats2 = stats
                        self.selectedName2 = name
                    }
                }))
                comparePlayersAndShowWinner()
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    func comparePlayersAndShowWinner() {
        guard let stats1 = selectedStats1, let stats2 = selectedStats2,
              let name1 = selectedName1, let name2 = selectedName2 else { return }

        let score1 = stats1.goals + stats1.behinds + stats1.kicks + stats1.handballs + stats1.marks + stats1.tackles
        let score2 = stats2.goals + stats2.behinds + stats2.kicks + stats2.handballs + stats2.marks + stats2.tackles

        if score1 > score2 {
            bestPlayerLabel.text = "🏅 \(name1) is the Best Player"
        } else if score2 > score1 {
            bestPlayerLabel.text = "🏅 \(name2) is the Best Player"
        } else {
            bestPlayerLabel.text = "🤝 It's a Tie!"
        }
    }



        func updatePlayerUI(button: UIButton, label: UILabel, image: UIImage?, name: String, stats: PlayerStats) {
            label.numberOfLines = 0
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 14)

            // Button image and title
            button.setTitle(name, for: .normal)
            button.setImage(image ?? UIImage(systemName: "person.crop.circle"), for: .normal)
            button.tintColor = .white
            button.imageView?.contentMode = .scaleAspectFill
            button.layer.cornerRadius = 8
            button.clipsToBounds = true

            // Adjust spacing
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: 70, left: -70, bottom: 0, right: 0)

            // Stats label
            label.text = """
            Goals: \(stats.goals)
            Behinds: \(stats.behinds)
            Kicks: \(stats.kicks)
            Handballs: \(stats.handballs)
            Marks: \(stats.marks)
            Tackles: \(stats.tackles)
            """
        }
    

        // MARK: - Actions
        @IBAction func player1ButtonTapped(_ sender: UIButton) {
            showPlayerPicker(isForPlayer1: true)
        }
        
        @IBAction func player2ButtonTapped(_ sender: UIButton) {
            showPlayerPicker(isForPlayer1: false)
        }
    }


