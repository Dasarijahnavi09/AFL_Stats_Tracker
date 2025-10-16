package au.edu.utas.kit305.aflstatstracker

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class PlayerStats(
    val name: String,
    val kicks: Int = 0,
    val handballs: Int = 0,
    val marks: Int = 0,
    val tackles: Int = 0,
    val goals: Int = 0,
    val behinds: Int = 0
) : Parcelable

