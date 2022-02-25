//
//  NotesTableViewController.swift
//  Notes_IOS
//
//  Created by Grekhem on 02.02.2022.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController {
    
    var notes: [NotesCore] = []
    @IBOutlet var noNotesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstStart()
        tableView.delegate = self
        tableView.dataSource = self
        noNotesLabel.center = self.view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTable()
    }
    
    func reloadTable() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NotesCore.fetchRequest() as NSFetchRequest<NotesCore>
        do {
            notes = try context.fetch(fetchRequest)
        } catch let error {
                print("Не удалось загрузить данные из-за ошибки \(error)")
            }
        tableView.reloadData()
        if notes.isEmpty {
            self.view.addSubview(noNotesLabel)
        } else {
            noNotesLabel.removeFromSuperview()
        }
    }
    
    func isFirstStart() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = FirstStart.fetchRequest() as NSFetchRequest<FirstStart>
        var first = Bool()
        do {
            first = try context.fetch(fetchRequest).isEmpty
        } catch let error {
                print("Не удалось загрузить данные из-за ошибки \(error)")
            }
        if first {
            let newNote = NotesCore(context: context)
            let first = FirstStart(context: context)
            newNote.titleCore = "Read me"
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 19)]
            newNote.noteCore = NSAttributedString(string: "Hello!\nTo add a new note press +.\nTo view and edit a note, click on it.\nSwipe left to delete a note.", attributes: attributes as [NSAttributedString.Key : Any])
            first.isFirst = false
            do {
                try context.save()
            } catch let error {
                print("Не удалось сохранить из-за ошибки \(error).")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = notes[indexPath.row].titleCore
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = notes[indexPath.row]
        guard let vc =  storyboard?.instantiateViewController(withIdentifier: "note") as? ReadNoteViewController else {
            return
        }
        vc.editNote = notes[indexPath.row]
        vc.noteTitle = note.titleCore!
        vc.note = note.noteCore as! NSAttributedString
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        context.delete(notes[indexPath.row])
        do {
            try context.save()
        } catch let error {
            print("Не удалось сохранить из-за ошибки \(error).")
        }
        reloadTable()
    }
}
