//
//  QuarterCell.swift
//  AFLStatsTracker
//
//  Created by Jahnavi Dasari on 18/5/2025.
//

import UIKit

class QuarterCell: UICollectionViewCell {
    let quarterLabel = UILabel()
        let team1ScoreLabel = UILabel()
        let team2ScoreLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
            styleCell()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupViews()
            styleCell()
        }

        private func setupViews() {
            // Add subviews
            contentView.addSubview(quarterLabel)
            contentView.addSubview(team1ScoreLabel)
            contentView.addSubview(team2ScoreLabel)

            // Enable Auto Layout
            quarterLabel.translatesAutoresizingMaskIntoConstraints = false
            team1ScoreLabel.translatesAutoresizingMaskIntoConstraints = false
            team2ScoreLabel.translatesAutoresizingMaskIntoConstraints = false

            // Constraints
            NSLayoutConstraint.activate([
                quarterLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                quarterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

                team1ScoreLabel.topAnchor.constraint(equalTo: quarterLabel.bottomAnchor, constant: 12),
                team1ScoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                team1ScoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

                team2ScoreLabel.topAnchor.constraint(equalTo: team1ScoreLabel.bottomAnchor, constant: 8),
                team2ScoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                team2ScoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                team2ScoreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
            ])
        }

        private func styleCell() {
            // Style the cell
            backgroundColor = UIColor.systemGray6
            layer.cornerRadius = 10
            layer.borderColor = UIColor.systemGray3.cgColor
            layer.borderWidth = 1

            quarterLabel.font = UIFont.boldSystemFont(ofSize: 18)
            team1ScoreLabel.font = UIFont.systemFont(ofSize: 16)
            team2ScoreLabel.font = UIFont.systemFont(ofSize: 16)

            quarterLabel.textAlignment = .center
            team1ScoreLabel.textAlignment = .center
            team2ScoreLabel.textAlignment = .center
        }

        func configure(quarter: Int, team1Score: String, team2Score: String) {
            quarterLabel.text = "Quarter \(quarter)"
            team1ScoreLabel.text = "Team 1: \(team1Score)"
            team2ScoreLabel.text = "Team 2: \(team2Score)"
        }
    }
