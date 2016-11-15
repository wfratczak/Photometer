//
//  MetersViewController.swift
//  Photometer
//
//  Created by Wojtek Frątczak on 11.11.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

import UIKit
import RealmSwift

class MetersViewController: UITableViewController {

    var meters: [Meter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        loadMeters()
    }

    private func loadMeters() {
        let realm = try! Realm()
        meters = Array(realm.objects(Meter.self))
        tableView.reloadData()
    }
    
    private func configureView() {
        
        
    }
    @IBAction func trashBarButtonItemAction(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @IBAction func addBarButtonItemAction(_ sender: AnyObject) {
        let alert = UIAlertController(title: "New meter", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Meter name"
        }
        let action = UIAlertAction(title: "OK", style: .default) { action in
            let meterName = alert.textFields?.first?.text
            let newMeter = Meter()
            newMeter.name = meterName!
            let realm = try! Realm()
            try! realm.write {
                realm.add(newMeter)
            }
            self.loadMeters()
        }
        alert.addAction(action)
        UIApplication.shared.keyWindow?.rootViewController!.show(alert, sender: self)
    }
    
    // MARK: - UITableView

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let meter = meters[indexPath.item]
            let realm = try! Realm()
            try! realm.write {
                realm.delete(meter)
            }
            self.meters.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let meter = meters[indexPath.item]
        cell.textLabel?.text = meter.name
        return cell
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MeterDetailsViewController, let indexPath = tableView.indexPathForSelectedRow {
            vc.meter = meters[indexPath.item]
        }
    }

}
