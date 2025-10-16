package au.edu.utas.kit305.aflstatstracker

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import au.edu.utas.kit305.aflstatstracker.databinding.AddPlayerBinding

class AddPlayerActivity : AppCompatActivity() {
    private lateinit var binding: AddPlayerBinding
    private var selectedPlayerImageUri: Uri? = null

    private val REQUEST_CODE_PICK_PLAYER_IMAGE = 2001

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = AddPlayerBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Upload image button click
        binding.btnUploadImage.setOnClickListener {
            pickImageFromGallery()
        }

        // Save player button
        binding.btnSavePlayer.setOnClickListener {
            val name = binding.edtPlayerName.text.toString().trim()
            val number = binding.edtPlayerNumber.text.toString().trim()
            val position = binding.edtPlayerPosition.text.toString().trim()

            if (name.isEmpty() || number.isEmpty() || position.isEmpty()) {
                Toast.makeText(this, "Please fill in all fields", Toast.LENGTH_SHORT).show()
            } else {
                // ✅ Create player object
                val newPlayer = Player(
                    name = name,
                    number = number,
                    position = position,
                    imageUri = selectedPlayerImageUri?.toString()?:"" // if you have imageUri in Player.kt
                )

                val resultIntent = Intent()
                resultIntent.putExtra("PLAYER", newPlayer) // ✅ MUST BE "PLAYER"
                setResult(Activity.RESULT_OK, resultIntent)
                finish()
            }
        }
    }

    private fun pickImageFromGallery() {
        val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
        startActivityForResult(intent, REQUEST_CODE_PICK_PLAYER_IMAGE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (resultCode == Activity.RESULT_OK && requestCode == REQUEST_CODE_PICK_PLAYER_IMAGE && data != null) {
            val imageUri = data.data
            if (imageUri != null) {
                selectedPlayerImageUri = imageUri
                binding.imgAflLogo.setImageURI(imageUri)
            }
        }
    }
}
