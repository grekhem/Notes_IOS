//
//  ReadNoteViewController.swift
//  Notes_IOS
//
//  Created by Grekhem on 02.02.2022.
//

import UIKit
import CoreData

class ReadNoteViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var noteField: UITextView! {
        didSet {
            noteField.delegate = self
        }
    }
    @IBOutlet weak var editFontView: UIView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var fontView: UIView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet var fontButtonCollection: [UIButton]!
    
    var rangeSelected = NSRange()
    var font = "Arial"
    var fontSize = 19
    public var editNote = NotesCore()
    public var noteTitle = ""
    public var note = NSAttributedString()
   
    @IBAction func EditAction(_ sender: UIBarButtonItem) {
        if editButton.title == "Edit" {
            titleField.isEnabled.toggle()
            noteField.isEditable.toggle()
            editButton.title = "Save"
            editFontView.isHidden = false
        } else if editButton.title == "Save" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            titleField.isEnabled.toggle()
            noteField.isEditable.toggle()
            editButton.title = "Edit"
            editFontView.isHidden = true
            if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
                let title = titleField.text
                let note = noteField.attributedText
                editNote.titleCore = title
                editNote.noteCore = note
                do {
                    try context.save()
                } catch let error {
                    print("Не удалось сохранить из-за ошибки \(error).")
                }
            }
        }
    }
    
    @IBAction func setupFont(_ sender: UIButton) {
        fontView.center = self.view.center
        self.view.addSubview(fontView)
    }
    
    @IBAction func chooseFont(_ sender: UIButton) {
        let defaultColor = sender.layer.backgroundColor
        font = sender.titleLabel?.text ?? "Arial"
        for i in fontButtonCollection {
            i.layer.backgroundColor = defaultColor
        }
        sender.layer.backgroundColor = CGColor(gray: 150, alpha: 0.5)
    }
    
    @IBAction func stepperSize(_ sender: UIStepper) {
        fontSize = Int(sender.value)
        sizeLabel.text = "\(fontSize)"
    }
    
    @IBAction func okFontButton(_ sender: Any) {
        if rangeSelected.length != 0 {
            let attributes = [NSAttributedString.Key.font: UIFont(name: font, size: CGFloat(fontSize))]
            let string = NSMutableAttributedString(attributedString: noteField.attributedText)
            string.addAttributes(attributes as [NSAttributedString.Key : Any], range: rangeSelected)
            noteField.attributedText = string
            } else {
                noteField.font = UIFont(name: font, size: CGFloat(fontSize))
            }
            fontView.removeFromSuperview()
    }
    
    @IBAction func cancelFont(_ sender: Any) {
        fontView.removeFromSuperview()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        rangeSelected = textView.selectedRange
     }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.text = noteTitle
        noteField.attributedText = note
        titleField.isEnabled = false
        noteField.isEditable = false
        for i in fontButtonCollection {
            i.layer.cornerRadius = 5
        }
        sizeLabel.text = "\(fontSize)"
        stepper.value = Double(fontSize)
        editFontView.isHidden = true
    }
}
