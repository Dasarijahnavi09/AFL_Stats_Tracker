package au.edu.utas.kit305.aflstatstracker

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import au.edu.utas.kit305.aflstatstracker.databinding.TeamSelectionBinding

class TeamSelectionActivity : AppCompatActivity() {
    private lateinit var binding: TeamSelectionBinding
    private var selectedLogo1Uri: Uri? = null
    private var selectedLogo2Uri: Uri? = null
    private var currentLogoButton: Int = 0

    private val REQUEST_CODE_CAMERA = 101
    private val REQUEST_CODE_GALLERY = 102

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = TeamSelectionBinding.inflate(layoutInflater)
        setContentView(binding.root)

        Toast.makeText(this, "Team Selection Loaded", Toast.LENGTH_SHORT).show()

        binding.btnUploadLogo1.setOnClickListener {
            currentLogoButton = 1
            showImagePickerDialog()
        }

        binding.btnUploadLogo2.setOnClickListener {
            currentLogoButton = 2
            showImagePickerDialog()
        }

        binding.btnContinue.setOnClickListener {
            val team1 = binding.edtTeam1Name.text.toString().trim()
            val team2 = binding.edtTeam2Name.text.toString().trim()

            if (team1.isEmpty() || team2.isEmpty()) {
                Toast.makeText(this, "Please enter both team names", Toast.LENGTH_SHORT).show()
            } else {
                val intent = Intent(this, PlayerSetupActivity::class.java)
                intent.putExtra("TEAM1_NAME", team1)
                intent.putExtra("TEAM2_NAME", team2)
                startActivity(intent)
            }
        }
    }

    private fun showImagePickerDialog() {
        val options = arrayOf("Camera", "Gallery")
        val builder = android.app.AlertDialog.Builder(this)
        builder.setTitle("Select Logo From")
        builder.setItems(options) { dialog, which ->
            when (which) {
                0 -> openCamera()
                1 -> openGallery()
            }
        }
        builder.show()
    }

    private fun openCamera() {
        val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        startActivityForResult(cameraIntent, REQUEST_CODE_CAMERA)
    }

    private fun openGallery() {
        val galleryIntent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
        startActivityForResult(galleryIntent, REQUEST_CODE_GALLERY)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (resultCode == Activity.RESULT_OK && data != null) {
            when (requestCode) {
                REQUEST_CODE_CAMERA -> {
                    val photo = data.extras?.get("data") as? Bitmap
                    if (photo != null) {
                        if (currentLogoButton == 1) {
                            binding.btnUploadLogo1.setImageBitmap(photo)
                        } else if (currentLogoButton == 2) {
                            binding.btnUploadLogo2.setImageBitmap(photo)
                        }
                    }
                }
                REQUEST_CODE_GALLERY -> {
                    val selectedImage: Uri? = data.data
                    if (selectedImage != null) {
                        if (currentLogoButton == 1) {
                            selectedLogo1Uri = selectedImage
                            binding.btnUploadLogo1.setImageURI(selectedImage)
                        } else if (currentLogoButton == 2) {
                            selectedLogo2Uri = selectedImage
                            binding.btnUploadLogo2.setImageURI(selectedImage)
                        }
                    }
                }
            }
        }
    }
}


