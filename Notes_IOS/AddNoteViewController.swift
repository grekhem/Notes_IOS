//
//  AddNoteViewController.swift
//  Notes_IOS
//
//  Created by Grekhem on 02.02.2022.
//

import Foundation
import UIKit
import CoreData

class AddNoteViewController: UIViewController, UITextViewDelegate {
    
    var rangeSelected = NSRange()
    var font = "Arial"
    var fontSize = 19
    
    @IBOutlet var fontView: UIView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet var fontButtonCollection: [UIButton]!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var noteField: UITextView! {
        didSet {
            noteField.delegate = self
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

    @IBAction func SaveAction(_ sender: UIBarButtonItem) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
            let title = titleField.text
            let note = noteField.attributedText
            let newNote = NotesCore(context: context)
            newNote.titleCore = title
            newNote.noteCore = note
            do {
                try context.save()
            } catch let error {
                print("Не удалось сохранить из-за ошибки \(error).")
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.becomeFirstResponder()
        for i in fontButtonCollection {
            i.layer.cornerRadius = 5
        }
        sizeLabel.text = "\(fontSize)"
        stepper.value = Double(fontSize)
    }
}
