package au.edu.utas.kit305.aflstatstracker

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.aflstatstracker.databinding.ItemQuarterBinding

class QuarterAdapter(private val quarters: List<QuarterStats>) :
    RecyclerView.Adapter<QuarterAdapter.QuarterViewHolder>() {

    inner class QuarterViewHolder(val ui: ItemQuarterBinding) : RecyclerView.ViewHolder(ui.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): QuarterViewHolder {
        val ui = ItemQuarterBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return QuarterViewHolder(ui)
    }

    override fun getItemCount(): Int = quarters.size

    override fun onBindViewHolder(holder: QuarterViewHolder, position: Int) {
        val quarter = quarters[position]
        holder.ui.txtQuarterTitle.text = "Quarter ${quarter.quarterNumber}"
        holder.ui.txtScore.text = "${quarter.team1Name}: ${quarter.team1Score} | ${quarter.team2Name}: ${quarter.team2Score}"
        holder.ui.txtActions.text = "Actions: ${quarter.actions.joinToString(", ")}"
    }
}
