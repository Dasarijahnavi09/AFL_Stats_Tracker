//
//  AddPlayerViewController.swift
//  AFLStatsTracker
//
//  Created by Jahnavi Dasari on 8/5/2025.
//
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit

class AddPlayerViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var positionField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var playerImage: UIImageView!
    
    var onSave: ((Player) -> Void)?
    var playerToEdit: Player?
    var isEditingTeam1: Bool?
    
    let positions = ["Forward", "Midfield", "Back", "Ruck"]
    var positionPicker = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberField.delegate = self
        positionField.delegate = self
        positionPicker.delegate = self
        positionPicker.dataSource = self
        positionField.inputView = positionPicker
        addDoneButtonToPicker()
        
        playerImage.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
                playerImage.addGestureRecognizer(tapGesture)
        
        if let player = playerToEdit {
                   nameField.text = player.name
                   numberField.text = "\(player.number)"
                   positionField.text = player.position
                   playerImage.image = player.image
                   saveButton.setTitle("Update", for: .normal)
               } else {
                   saveButton.setTitle("Add", for: .normal)
               }
           }

    
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty,
                  let numberText = numberField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let number = Int(numberText),
                  let position = positionField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !position.isEmpty else {
                showAlert("Please fill in all fields correctly.")
                return
            }
            
            let positionRegex = "^[a-zA-Z ]+$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", positionRegex)
            if !predicate.evaluate(with: position) {
                showAlert("Position should only contain letters.")
                return
            }

            // ✅ Save player with image locally (optional), not uploading
            let player = Player(name: name, number: number, position: position, image: playerImage.image)
        let confirmationAlert = UIAlertController(title: "Success", message: "Player '\(name)' has been added!", preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.onSave?(player)
                self.dismiss(animated: true)
            }))
            present(confirmationAlert, animated: true)
        }

            // MARK: - PickerView
            func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
            func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
                return positions.count
            }
            func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
                return positions[row]
            }
            func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                positionField.text = positions[row]
            }

            // MARK: - Done button for Picker
            func addDoneButtonToPicker() {
                let toolbar = UIToolbar()
                toolbar.sizeToFit()
                let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
                toolbar.setItems([flex, done], animated: false)
                positionField.inputAccessoryView = toolbar
            }
            
            @objc func doneTapped() {
                positionField.resignFirstResponder()
            }

            // MARK: - Restrict Number Input
            func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                if textField == numberField {
                    return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
                }
                return true
            }

            // MARK: - Alert
            func showAlert(_ message: String) {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }

            // MARK: - Image Picker
            @objc func selectImage() {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                present(picker, animated: true)
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let selectedImage = info[.originalImage] as? UIImage {
                    playerImage.image = selectedImage
                }
                dismiss(animated: true)
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                dismiss(animated: true)
            }
        }


