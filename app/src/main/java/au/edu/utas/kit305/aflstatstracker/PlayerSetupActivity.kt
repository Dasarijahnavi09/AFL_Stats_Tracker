package au.edu.utas.kit305.aflstatstracker

import au.edu.utas.kit305.aflstatstracker.PlayerAdapter
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import au.edu.utas.kit305.aflstatstracker.databinding.PlayerSetupBinding

class PlayerSetupActivity : AppCompatActivity() {
    private lateinit var binding: PlayerSetupBinding

    private lateinit var team1Name: String
    private lateinit var team2Name: String

    private val team1Players = mutableListOf<Player>()
    private val team2Players = mutableListOf<Player>()

    private lateinit var team1Adapter: PlayerAdapter
    private lateinit var team2Adapter: PlayerAdapter


    private var addingToTeam: Int = 1

    private val addPlayerLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val data = result.data
            val player = data?.getParcelableExtra<Player>("PLAYER")
            if (player != null) {
                if (addingToTeam == 1) {
                    team1Players.add(player)
                    team1Adapter.notifyItemInserted(team1Players.size - 1)
                } else {
                    team2Players.add(player)
                    team2Adapter.notifyItemInserted(team2Players.size - 1)
                }
                Toast.makeText(this, "Added ${player.name}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = PlayerSetupBinding.inflate(layoutInflater)
        setContentView(binding.root)

        team1Name = intent.getStringExtra("TEAM1_NAME") ?: "Team 1"
        team2Name = intent.getStringExtra("TEAM2_NAME") ?: "Team 2"

        binding.txtTeam1.text = "Team 1: $team1Name"
        binding.txtTeam2.text = "Team 2: $team2Name"

        team1Adapter = PlayerAdapter(team1Players, onClick = { updateUI() }, allowDelete = true)
        team2Adapter = PlayerAdapter(team2Players, onClick = { updateUI() }, allowDelete = true)


        binding.Team1PlayerList.adapter = team1Adapter
        binding.Team1PlayerList.layoutManager = LinearLayoutManager(this)

        binding.Team2PlayerList.adapter = team2Adapter
        binding.Team2PlayerList.layoutManager = LinearLayoutManager(this)

        // Add Player Buttons
        binding.button4.setOnClickListener {
            addingToTeam = 1
            launchAddPlayer(team1Name)
        }

        binding.button5.setOnClickListener {
            addingToTeam = 2
            launchAddPlayer(team2Name)
        }

        // Start match button
        binding.btnStartMatch.setOnClickListener {
            if (team1Players.size < 2 || team2Players.size < 2) {
                Toast.makeText(
                    this,
                    "Please add at least 2 players in each team",
                    Toast.LENGTH_SHORT
                ).show()
                return@setOnClickListener
            }

            val intent = Intent(this, MatchRecordingActivity::class.java)
            intent.putExtra("TEAM1_NAME", team1Name)
            intent.putExtra("TEAM2_NAME", team2Name)
            intent.putParcelableArrayListExtra("TEAM1_PLAYERS", ArrayList(team1Players))
            intent.putParcelableArrayListExtra("TEAM2_PLAYERS", ArrayList(team2Players))
            startActivity(intent)
        }

    }
        private fun launchAddPlayer(team: String) {
        val intent = Intent(this, AddPlayerActivity::class.java)
        intent.putExtra("TEAM_NAME", team)
        addPlayerLauncher.launch(intent)
    }
    private fun updateUI() {
        team1Adapter.notifyDataSetChanged()
        team2Adapter.notifyDataSetChanged()
    }


}








