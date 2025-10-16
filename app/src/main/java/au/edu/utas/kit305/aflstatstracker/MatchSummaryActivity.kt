package au.edu.utas.kit305.aflstatstracker

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import au.edu.utas.kit305.aflstatstracker.databinding.MatchSummaryBinding
import com.google.firebase.firestore.FirebaseFirestore

class MatchSummaryActivity : AppCompatActivity() {
    private lateinit var binding: MatchSummaryBinding
    private lateinit var players: ArrayList<Player>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = MatchSummaryBinding.inflate(layoutInflater)
        setContentView(binding.root)

        players = arrayListOf() // initialize empty first

        val matchId = intent.getStringExtra("MATCH_ID")
        val db = FirebaseFirestore.getInstance()

        if (matchId != null) {
            db.collection("matches").document(matchId).get()
                .addOnSuccessListener { doc ->
                    val team1 = doc.getString("team1") ?: "Team A"
                    val team2 = doc.getString("team2") ?: "Team B"
                    binding.summaryTitle.text = "$team1 vs $team2"

                    val quarterList = (doc["quarters"] as? List<Map<String, Any>>)?.map { q ->
                        QuarterStats(
                            quarterNumber = (q["quarterNumber"] as Long).toInt(),
                            team1Name = q["team1Name"] as String,
                            team2Name = q["team2Name"] as String,
                            team1Score = q["team1Score"] as String,
                            team2Score = q["team2Score"] as String,
                            actions = q["actions"] as List<String>
                        )
                    } ?: emptyList()

                    val playerStatsList = (doc["playerStats"] as? List<Map<String, Any>>)?.map { p ->
                        PlayerStats(
                            name = p["name"] as String,
                            kicks = (p["kicks"] as Long).toInt(),
                            handballs = (p["handballs"] as Long).toInt(),
                            marks = (p["marks"] as Long).toInt(),
                            tackles = (p["tackles"] as Long).toInt(),
                            goals = (p["goals"] as Long).toInt(),
                            behinds = (p["behinds"] as Long).toInt()
                        )
                    } ?: emptyList()

                    // ✅ Correct way to create players list
                    players = ArrayList(playerStatsList.map { stat ->
                        Player(
                            name = stat.name,
                            number = "0",    // Default 0
                            position = "",   // Default empty
                            kicks = stat.kicks,
                            handballs = stat.handballs,
                            marks = stat.marks,
                            tackles = stat.tackles,
                            goals = stat.goals,
                            behinds = stat.behinds
                        )
                    })

                    binding.quartersRecyclerView.layoutManager = LinearLayoutManager(this)
                    binding.quartersRecyclerView.adapter = QuarterAdapter(quarterList)

                    val last = quarterList.lastOrNull()
                    binding.txtFinalScore.text = if (last != null)
                        "Final Score:\n${last.team1Score} - ${last.team2Score}"
                    else
                        "Final Score:\nNo data available"

                    val bestPlayer = playerStatsList.maxByOrNull { (it.goals * 6) + it.tackles }
                    binding.txtPlayerOfMatch.text = "🏆 Player of the Match: ${bestPlayer?.name ?: "No Data"}"

                    // ✅ Sending BOTH PLAYER_STATS and PLAYERS_LIST correctly
                    binding.btnPlayerStats.setOnClickListener {
                        val statsIntent = Intent(this, PlayerStatsActivity::class.java)
                        statsIntent.putParcelableArrayListExtra("PLAYER_STATS", ArrayList(playerStatsList))
                        statsIntent.putParcelableArrayListExtra("PLAYERS_LIST", players)
                        startActivity(statsIntent)
                    }

                    binding.btnShareSummary.setOnClickListener {
                        val shareText = buildString {
                            append("Match Summary\n$team1 vs $team2\n\n")
                            for (q in quarterList) {
                                append("Q${q.quarterNumber}: ${q.team1Score} - ${q.team2Score}\n")
                            }
                            append("\nPlayer of the Match: ${bestPlayer?.name ?: "No Data"}")
                        }

                        val shareIntent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, shareText)
                        }
                        startActivity(Intent.createChooser(shareIntent, "Share Match Summary via"))
                    }
                }
                .addOnFailureListener {
                    binding.txtFinalScore.text = "Failed to load summary"
                }
        } else {
            val quarters = intent.getParcelableArrayListExtra<QuarterStats>("SUMMARY") ?: arrayListOf()
            val playerStats = intent.getParcelableArrayListExtra<PlayerStats>("PLAYER_STATS") ?: arrayListOf()
            players = intent.getParcelableArrayListExtra<Player>("PLAYERS_LIST") ?: arrayListOf()

            val team1 = intent.getStringExtra("TEAM1_NAME") ?: "Team A"
            val team2 = intent.getStringExtra("TEAM2_NAME") ?: "Team B"
            binding.summaryTitle.text = "$team1 vs $team2"

            binding.quartersRecyclerView.layoutManager = LinearLayoutManager(this)
            binding.quartersRecyclerView.adapter = QuarterAdapter(quarters)

            val last = quarters.lastOrNull()
            binding.txtFinalScore.text = if (last != null) {
                "Final Score:\n${last.team1Score} - ${last.team2Score}"
            } else {
                "Final Score:\nNo data available"
            }

            val bestPlayer = playerStats.maxByOrNull { (it.goals * 6) + it.tackles }
            binding.txtPlayerOfMatch.text = "🏆 Player of the Match: ${bestPlayer?.name ?: "No Data"}"

            binding.btnPlayerStats.setOnClickListener {
                val intent = Intent(this, PlayerStatsActivity::class.java)
                intent.putParcelableArrayListExtra("PLAYER_STATS", ArrayList(playerStats))
                intent.putParcelableArrayListExtra("PLAYERS_LIST", players)
                startActivity(intent)
            }

            binding.btnShareSummary.setOnClickListener {
                val shareText = buildString {
                    append("Match Summary\n$team1 vs $team2\n\n")
                    for (q in quarters) {
                        append("Q${q.quarterNumber}: ${q.team1Score} - ${q.team2Score}\n")
                    }
                    append("\nPlayer of the Match: ${bestPlayer?.name ?: "No Data"}")
                }

                val shareIntent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, shareText)
                }
                startActivity(Intent.createChooser(shareIntent, "Share Match Summary via"))
            }
        }
    }
}
