package au.edu.utas.kit305.aflstatstracker

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import au.edu.utas.kit305.aflstatstracker.databinding.ActivityMainBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Navigate to Create Match screen
        binding.btnCreateMatch.setOnClickListener {
            val intent = Intent(this, TeamSelectionActivity::class.java)
            startActivity(intent)
            Log.d("MainActivity", "Create Match Clicked")
            Toast.makeText(this, "Create Match Clicked", Toast.LENGTH_SHORT).show()

        }

        // Navigate to Previous Match History screen
        binding.btnMatchHistory.setOnClickListener {
            val intent = Intent(this, MatchHistoryActivity::class.java)
            startActivity(intent)
        }
        val db = Firebase.firestore
        Log.d("FIREBASE", "Firebase connected: ${db.app.name}")
    }
}

