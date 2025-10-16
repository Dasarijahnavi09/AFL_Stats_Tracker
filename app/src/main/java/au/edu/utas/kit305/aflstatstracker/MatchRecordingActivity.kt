package au.edu.utas.kit305.aflstatstracker

import android.util.Log
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import au.edu.utas.kit305.aflstatstracker.databinding.MatchRecordingBinding
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore

class MatchRecordingActivity : AppCompatActivity() {
    private lateinit var binding: MatchRecordingBinding
    private lateinit var team1Name: String
    private lateinit var team2Name: String
    private lateinit var team1Players: MutableList<Player>
    private lateinit var team2Players: MutableList<Player>
    private lateinit var adapter1: PlayerAdapter
    private lateinit var adapter2: PlayerAdapter
    private var selectedPlayer: Player? = null
    private lateinit var matchId: String
    private val db = FirebaseFirestore.getInstance()
    private val quarterList = mutableListOf<QuarterStats>()

    private var team1Goals = 0
    private var team1Behinds = 0
    private var team2Goals = 0
    private var team2Behinds = 0
    private var lastAction = ""
    private var currentQuarter = 1

    // 🔥 NEW variables for Undo
    private var lastActionId: String? = null
    private var lastActionType: String? = null
    private var lastPlayer: Player? = null
    private var lastPlayerTeam: Int = 0 // 1 or 2

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = MatchRecordingBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Get data from intent
        team1Name = intent.getStringExtra("TEAM1_NAME") ?: "Team A"
        team2Name = intent.getStringExtra("TEAM2_NAME") ?: "Team B"
        team1Players = intent.getParcelableArrayListExtra("TEAM1_PLAYERS") ?: arrayListOf()
        team2Players = intent.getParcelableArrayListExtra("TEAM2_PLAYERS") ?: arrayListOf()

        binding.txtMatchTitle.text = "$team1Name vs $team2Name"
        binding.txtCurrentScore.text = "0.0 (0) - 0.0 (0)"

        adapter1 = PlayerAdapter(team1Players, onClick = { player -> selectPlayer(player, team1Name) }, allowDelete = false)
        adapter2 = PlayerAdapter(team2Players, onClick = { player -> selectPlayer(player, team2Name) }, allowDelete = false)


        binding.team1RecyclerView.layoutManager = LinearLayoutManager(this)
        binding.team1RecyclerView.adapter = adapter1

        binding.team2RecyclerView.layoutManager = LinearLayoutManager(this)
        binding.team2RecyclerView.adapter = adapter2

        // Action buttons
        binding.btnUndo.setOnClickListener { undoLastAction() }
        binding.btnKick.setOnClickListener { recordAction("Kick") }
        binding.btnHandball.setOnClickListener { recordAction("Handball") }
        binding.btnMark.setOnClickListener { recordAction("Mark") }
        binding.btnTackle.setOnClickListener { recordAction("Tackle") }
        binding.btnGoal.setOnClickListener { recordAction("Goal") }
        binding.btnBehind.setOnClickListener { recordAction("Behind") }

        binding.btnEndMatch.setOnClickListener { endMatch() }
        binding.btnEndQuarter.setOnClickListener { endQuarter() }

        // Firestore: create match
        val matchData = hashMapOf(
            "team1" to team1Name,
            "team2" to team2Name,
            "timestamp" to FieldValue.serverTimestamp()
        )

        db.collection("matches")
            .add(matchData)
            .addOnSuccessListener {
                matchId = it.id
                Toast.makeText(this, "Match started", Toast.LENGTH_SHORT).show()
            }
            .addOnFailureListener {
                Toast.makeText(this, "Failed to start match", Toast.LENGTH_SHORT).show()
            }
    }

    private fun selectPlayer(player: Player, team: String) {
        selectedPlayer = player
        Toast.makeText(this, "${player.name} from $team selected", Toast.LENGTH_SHORT).show()
    }

    private fun recordAction(action: String) {
        if (selectedPlayer == null) {
            Toast.makeText(this, "Please select a player", Toast.LENGTH_SHORT).show()
            return
        }

        val team = if (team1Players.contains(selectedPlayer)) 1 else 2

        // Track player stats
        when (action) {
            "Kick" -> selectedPlayer?.kicks = selectedPlayer?.kicks?.plus(1) ?: 1
            "Handball" -> selectedPlayer?.handballs = selectedPlayer?.handballs?.plus(1) ?: 1
            "Mark" -> selectedPlayer?.marks = selectedPlayer?.marks?.plus(1) ?: 1
            "Tackle" -> selectedPlayer?.tackles = selectedPlayer?.tackles?.plus(1) ?: 1
            "Goal" -> {
                if (lastAction != "Kick") {
                    Toast.makeText(this, "Goal must follow a Kick", Toast.LENGTH_SHORT).show()
                    return
                }
                selectedPlayer?.goals = selectedPlayer?.goals?.plus(1) ?: 1
                if (team == 1) team1Goals++ else team2Goals++
            }
            "Behind" -> {
                if (lastAction != "Kick" && lastAction != "Handball") {
                    Toast.makeText(this, "Behind must follow Kick or Handball", Toast.LENGTH_SHORT).show()
                    return
                }
                selectedPlayer?.behinds = selectedPlayer?.behinds?.plus(1) ?: 1
                if (team == 1) team1Behinds++ else team2Behinds++
            }
        }

        lastAction = action
        updateScoreboard()

        val actionData = hashMapOf(
            "playerId" to selectedPlayer!!.number,
            "playerName" to selectedPlayer!!.name,
            "action" to action,
            "team" to if (team == 1) team1Name else team2Name,
            "timestamp" to FieldValue.serverTimestamp()
        )

        db.collection("matches").document(matchId).collection("actions")
            .add(actionData)
            .addOnSuccessListener { docRef ->
                lastActionId = docRef.id
                lastActionType = action
                lastPlayer = selectedPlayer
                lastPlayerTeam = team
                Toast.makeText(this, "$action recorded for ${selectedPlayer!!.name}", Toast.LENGTH_SHORT).show()
            }
            .addOnFailureListener {
                Toast.makeText(this, "Failed to record $action", Toast.LENGTH_SHORT).show()
            }
    }

    private fun undoLastAction() {
        if (lastActionId == null || lastPlayer == null) {
            Toast.makeText(this, "No action to undo", Toast.LENGTH_SHORT).show()
            return
        }

        db.collection("matches").document(matchId).collection("actions").document(lastActionId!!)
            .delete()
            .addOnSuccessListener {
                Toast.makeText(this, "Last action undone!", Toast.LENGTH_SHORT).show()

                // Reverse stats
                when (lastActionType) {
                    "Kick" -> lastPlayer?.kicks = (lastPlayer?.kicks ?: 1) - 1
                    "Handball" -> lastPlayer?.handballs = (lastPlayer?.handballs ?: 1) - 1
                    "Mark" -> lastPlayer?.marks = (lastPlayer?.marks ?: 1) - 1
                    "Tackle" -> lastPlayer?.tackles = (lastPlayer?.tackles ?: 1) - 1
                    "Goal" -> {
                        lastPlayer?.goals = (lastPlayer?.goals ?: 1) - 1
                        if (lastPlayerTeam == 1) team1Goals-- else team2Goals--
                    }
                    "Behind" -> {
                        lastPlayer?.behinds = (lastPlayer?.behinds ?: 1) - 1
                        if (lastPlayerTeam == 1) team1Behinds-- else team2Behinds--
                    }
                }

                updateScoreboard()

                // Clear last action
                lastActionId = null
                lastActionType = null
                lastPlayer = null
            }
            .addOnFailureListener {
                Toast.makeText(this, "Failed to undo last action", Toast.LENGTH_SHORT).show()
            }
    }

    private fun updateScoreboard() {
        val team1Total = team1Goals * 6 + team1Behinds
        val team2Total = team2Goals * 6 + team2Behinds
        binding.txtCurrentScore.text = "$team1Goals.$team1Behinds ($team1Total) - $team2Goals.$team2Behinds ($team2Total)"
    }

    private fun updateQuarterDisplay() {
        binding.txtCurrentScore.text = "Quarter $currentQuarter\n" +
                "$team1Goals.$team1Behinds (${team1Goals * 6 + team1Behinds}) - " +
                "$team2Goals.$team2Behinds (${team2Goals * 6 + team2Behinds})"
    }

    private fun disableActionButtons() {
        binding.btnKick.isEnabled = false
        binding.btnHandball.isEnabled = false
        binding.btnMark.isEnabled = false
        binding.btnTackle.isEnabled = false
        binding.btnGoal.isEnabled = false
        binding.btnBehind.isEnabled = false
    }

    private fun endMatch() {
        Toast.makeText(this, "Match Ended", Toast.LENGTH_SHORT).show()
        disableActionButtons()

        if (quarterList.isEmpty() || quarterList.lastOrNull()?.quarterNumber != currentQuarter) {
            quarterList.add(
                QuarterStats(
                    quarterNumber = currentQuarter,
                    team1Name = team1Name,
                    team2Name = team2Name,
                    team1Score = "$team1Goals.$team1Behinds (${team1Goals * 6 + team1Behinds})",
                    team2Score = "$team2Goals.$team2Behinds (${team2Goals * 6 + team2Behinds})",
                    actions = listOf("End of Quarter $currentQuarter")
                )
            )
        }

        val summaryData = hashMapOf(
            "team1" to team1Name,
            "team2" to team2Name,
            "timestamp" to FieldValue.serverTimestamp(),
            "quarters" to quarterList.map {
                mapOf(
                    "quarterNumber" to it.quarterNumber,
                    "team1Name" to it.team1Name,
                    "team2Name" to it.team2Name,
                    "team1Score" to it.team1Score,
                    "team2Score" to it.team2Score,
                    "actions" to it.actions
                )
            },
            "playerStats" to generatePlayerStats().map {
                mapOf(
                    "name" to it.name,
                    "kicks" to it.kicks,
                    "handballs" to it.handballs,
                    "marks" to it.marks,
                    "tackles" to it.tackles,
                    "goals" to it.goals,
                    "behinds" to it.behinds
                )
            }
        )

        db.collection("matches").document(matchId)
            .set(summaryData)
            .addOnSuccessListener {
                val intent = Intent(this, MatchSummaryActivity::class.java)
                intent.putExtra("MATCH_ID", matchId)
                startActivity(intent)
                finish()
            }
            .addOnFailureListener {
                Toast.makeText(this, "Failed to update summary", Toast.LENGTH_SHORT).show()
            }
    }

    private fun endQuarter() {
        if (currentQuarter < 4) {
            quarterList.add(
                QuarterStats(
                    quarterNumber = currentQuarter,
                    team1Name = team1Name,
                    team2Name = team2Name,
                    team1Score = "$team1Goals.$team1Behinds (${team1Goals * 6 + team1Behinds})",
                    team2Score = "$team2Goals.$team2Behinds (${team2Goals * 6 + team2Behinds})",
                    actions = listOf("End of Quarter $currentQuarter")
                )
            )
            currentQuarter++
            updateQuarterDisplay()
            Toast.makeText(this, "Moved to Quarter $currentQuarter", Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this, "Final quarter already in progress", Toast.LENGTH_SHORT).show()
        }
    }

    private fun generatePlayerStats(): ArrayList<PlayerStats> {
        val statsList = ArrayList<PlayerStats>()
        (team1Players + team2Players).forEach { player ->
            statsList.add(
                PlayerStats(
                    name = player.name,
                    kicks = player.kicks,
                    handballs = player.handballs,
                    marks = player.marks,
                    tackles = player.tackles,
                    goals = player.goals,
                    behinds = player.behinds
                )
            )
        }
        return statsList
    }
}

