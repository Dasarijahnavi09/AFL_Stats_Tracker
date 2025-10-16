package au.edu.utas.kit305.aflstatstracker

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class MatchRecord(
    val team1: String = "",
    val team2: String = "",
    val timestamp: com.google.firebase.Timestamp? = null,
    val matchId: String = "" // optional for identifying the document
) : Parcelable
