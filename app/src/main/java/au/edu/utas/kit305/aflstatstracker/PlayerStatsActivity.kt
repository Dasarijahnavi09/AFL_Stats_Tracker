package au.edu.utas.kit305.aflstatstracker

import android.app.AlertDialog
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import au.edu.utas.kit305.aflstatstracker.databinding.PlayerStatsBinding

class PlayerStatsActivity : AppCompatActivity() {
    private lateinit var binding: PlayerStatsBinding
    private lateinit var players: List<Player>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = PlayerStatsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        players = intent.getParcelableArrayListExtra("PLAYERS_LIST") ?: emptyList()
        val playerStats = intent.getParcelableArrayListExtra<PlayerStats>("PLAYER_STATS") ?: arrayListOf()

        binding.recyclerViewPlayerStats.layoutManager = LinearLayoutManager(this)
        binding.recyclerViewPlayerStats.adapter = PlayerStatsAdapter(playerStats)
        binding.btnComparePlayers.setOnClickListener {
            showComparePlayersDialog()
        }
    }
    private fun showComparePlayersDialog() {
        val playerNames = players.map { it.name }.toTypedArray()

        var selectedPlayer1 = -1
        var selectedPlayer2 = -1

        AlertDialog.Builder(this)
            .setTitle("Select First Player")
            .setItems(playerNames) { _, which ->
                selectedPlayer1 = which

                AlertDialog.Builder(this)
                    .setTitle("Select Second Player")
                    .setItems(playerNames) { _, which2 ->
                        selectedPlayer2 = which2

                        val p1 = players[selectedPlayer1]
                        val p2 = players[selectedPlayer2]

                        var player1Wins = 0
                        var player2Wins = 0

                        fun compareStat(statName: String, stat1: Int, stat2: Int): String {
                            val winner = when {
                                stat1 > stat2 -> {
                                    player1Wins++
                                    "${stat1} vs $stat2"
                                }
                                stat2 > stat1 -> {
                                    player2Wins++
                                    "$stat1 vs ${stat2}"
                                }
                                else -> "$stat1 vs $stat2"
                            }
                            return "$statName\t$winner"
                        }

                        val comparison = """
                        ${p1.name} vs ${p2.name}
                        
                        ${compareStat("Kicks", p1.kicks, p2.kicks)}
                        ${compareStat("Handballs", p1.handballs, p2.handballs)}
                        ${compareStat("Marks", p1.marks, p2.marks)}
                        ${compareStat("Tackles", p1.tackles, p2.tackles)}
                        ${compareStat("Goals", p1.goals, p2.goals)}
                        ${compareStat("Behinds", p1.behinds, p2.behinds)}
                        
                        🏆 ${if (player1Wins > player2Wins) "${p1.name} wins $player1Wins categories!"
                        else if (player2Wins > player1Wins) "${p2.name} wins $player2Wins categories!"
                        else "It's a tie!"}
                    """.trimIndent()

                        AlertDialog.Builder(this)
                            .setTitle("Player Comparison")
                            .setMessage(comparison)
                            .setPositiveButton("OK", null)
                            .show()
                    }
                    .show()
            }
            .show()
    }


    private fun showComparison(index1: Int, index2: Int) {
        val p1 = players[index1]
        val p2 = players[index2]

        val comparison = """
        🏉 ${p1.name} vs ${p2.name}
        
        Kicks: ${p1.kicks} vs ${p2.kicks}
        Handballs: ${p1.handballs} vs ${p2.handballs}
        Marks: ${p1.marks} vs ${p2.marks}
        Tackles: ${p1.tackles} vs ${p2.tackles}
        Goals: ${p1.goals} vs ${p2.goals}
        Behinds: ${p1.behinds} vs ${p2.behinds}
    """.trimIndent()

        AlertDialog.Builder(this)
            .setTitle("Player Comparison")
            .setMessage(comparison)
            .setPositiveButton("OK", null)
            .show()
    }

}

