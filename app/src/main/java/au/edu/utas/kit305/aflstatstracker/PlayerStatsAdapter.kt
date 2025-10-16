package au.edu.utas.kit305.aflstatstracker

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.aflstatstracker.databinding.ItemPlayerStatsBinding

class PlayerStatsAdapter(
    private val players: List<PlayerStats>):


    RecyclerView.Adapter<PlayerStatsAdapter.PlayerStatsViewHolder>() {

    inner class PlayerStatsViewHolder(val ui: ItemPlayerStatsBinding) : RecyclerView.ViewHolder(ui.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PlayerStatsViewHolder {
        val ui = ItemPlayerStatsBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return PlayerStatsViewHolder(ui)
    }

    override fun getItemCount(): Int = players.size

    override fun onBindViewHolder(holder: PlayerStatsViewHolder, position: Int) {
        val player = players[position]
        holder.ui.playerName.text = player.name
        holder.ui.playerStats.text =
            "Kicks: ${player.kicks}, Handballs: ${player.handballs}, Marks: ${player.marks}, " +
                    "Tackles: ${player.tackles}, Goals: ${player.goals}, Behinds: ${player.behinds}"
    }
}


