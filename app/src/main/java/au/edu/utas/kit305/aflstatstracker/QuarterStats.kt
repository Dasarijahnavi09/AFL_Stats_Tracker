package au.edu.utas.kit305.aflstatstracker

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class QuarterStats(
    val quarterNumber: Int,
    val team1Name: String,
    val team2Name: String,
    val team1Score: String,
    val team2Score: String,
    val actions: List<String>
) : Parcelable