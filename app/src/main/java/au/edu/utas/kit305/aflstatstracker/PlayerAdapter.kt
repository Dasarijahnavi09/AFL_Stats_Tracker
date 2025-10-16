package au.edu.utas.kit305.aflstatstracker

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.aflstatstracker.databinding.ItemPlayerBinding

class PlayerAdapter(
    private val players: MutableList<Player>,
    private val onClick: (Player) -> Unit,
    private val allowDelete: Boolean    // <-- NEW: Add a flag
) : RecyclerView.Adapter<PlayerAdapter.PlayerViewHolder>() {

    inner class PlayerViewHolder(val binding: ItemPlayerBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(player: Player) {
            binding.txtPlayerName.text = player.name
            binding.txtPlayerNumber.text = "No. ${player.number}"
            binding.txtPlayerPosition.text = player.position

            binding.root.setOnClickListener {
                onClick(player)
            }

            if (allowDelete) {
                binding.btnDelete.visibility = View.VISIBLE
                binding.btnDelete.setOnClickListener {
                    deletePlayer(adapterPosition)
                }
            } else {
                binding.btnDelete.visibility = View.GONE
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PlayerViewHolder {
        val binding = ItemPlayerBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return PlayerViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PlayerViewHolder, position: Int) {
        holder.bind(players[position])
    }

    override fun getItemCount(): Int = players.size

    private fun deletePlayer(position: Int) {
        if (position != RecyclerView.NO_POSITION) {
            players.removeAt(position)
            notifyItemRemoved(position)
        }
    }
}




