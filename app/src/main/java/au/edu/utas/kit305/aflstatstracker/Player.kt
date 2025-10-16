package au.edu.utas.kit305.aflstatstracker

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Player(
    val name: String = "",
    val number: String = "",
    val position: String = "",
    val team: String = "",
    val imageUri: String = "",
    var lastAction: String? = null,

    var kicks: Int = 0,
    var handballs: Int = 0,
    var marks: Int = 0,
    var tackles: Int = 0,
    var goals: Int = 0,
    var behinds: Int = 0
) : Parcelable


