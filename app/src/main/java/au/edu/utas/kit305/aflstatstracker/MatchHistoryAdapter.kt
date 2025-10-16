package au.edu.utas.kit305.aflstatstracker

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.aflstatstracker.databinding.ItemMatchBinding

class MatchHistoryAdapter(
    private val matches: List<MatchRecord>,
    private val onItemClick: (MatchRecord) -> Unit
) : RecyclerView.Adapter<MatchHistoryAdapter.MatchViewHolder>() {

    inner class MatchViewHolder(val binding: ItemMatchBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MatchViewHolder {
        val binding = ItemMatchBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return MatchViewHolder(binding)
    }

    override fun onBindViewHolder(holder: MatchViewHolder, position: Int) {
        val match = matches[position]
        holder.binding.txtMatchTitle.text = "${match.team1} vs ${match.team2}"
        holder.binding.txtDate.text = match.timestamp?.toDate().toString()

        // 🔽 Pass matchId to SummaryActivity
        holder.binding.root.setOnClickListener {
            onItemClick(match)
        }
    }

    override fun getItemCount(): Int = matches.size
}
