package au.edu.utas.kit305.aflstatstracker

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import au.edu.utas.kit305.aflstatstracker.databinding.MatchHistoryBinding
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query

class MatchHistoryActivity : AppCompatActivity() {
    private lateinit var binding: MatchHistoryBinding
    private val db = FirebaseFirestore.getInstance()
    private val matchList = mutableListOf<MatchRecord>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = MatchHistoryBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val adapter = MatchHistoryAdapter(matchList) { selectedMatch ->
            val intent = Intent(this, MatchSummaryActivity::class.java)
            intent.putExtra("MATCH_ID", selectedMatch.matchId)
            startActivity(intent)
        }

        binding.recyclerViewMatches.layoutManager = LinearLayoutManager(this)
        binding.recyclerViewMatches.adapter = adapter

        db.collection("matches")
            .orderBy("timestamp", Query.Direction.DESCENDING)
            .get()
            .addOnSuccessListener { documents ->
                for (doc in documents) {
                    val match = MatchRecord(
                        team1 = doc.getString("team1") ?: "",
                        team2 = doc.getString("team2") ?: "",
                        timestamp = doc.getTimestamp("timestamp"),
                        matchId = doc.id
                    )
                    matchList.add(match)
                }
                adapter.notifyDataSetChanged()
            }
            .addOnFailureListener {
                Toast.makeText(this, "Failed to load match history", Toast.LENGTH_SHORT).show()
            }
    }
}
