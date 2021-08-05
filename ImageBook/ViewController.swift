//
//  ViewController.swift
//  ImageBook
//
//  Created by Abdussamed on 5.08.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var nameArray = [String]()
    private var uuidArray = [UUID]()
    var selectedID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem:UIBarButtonItem.SystemItem.add, target: self, action: #selector(addNewImg))
        
        navigationItem.title = "Image Book"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
        getData()
    }
    
    @objc private func getData(){
        nameArray.removeAll(keepingCapacity: false)
        uuidArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageBook")
        fetchRequest.returnsObjectsAsFaults = false
    
        
        do{
            let results = try context.fetch(fetchRequest)
            
            for i in results as![NSManagedObject] {
                if let name = i.value(forKey: "name") as? String{
                    nameArray.append(name)
                }
                
                if let uuid = i.value(forKey: "id") as? UUID {
                    uuidArray.append(uuid)
                }
                
                tableView.reloadData()
            
            }
        }
        
        catch {
            print("error")
        }
    }

    @objc func addNewImg(){
        selectedID = nil
        performSegue(withIdentifier: "vcToDetailVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uuidArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID = uuidArray[indexPath.row]
        performSegue(withIdentifier: "vcToDetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vcToDetailVC" {
            let destinationVC = segue.destination as! DetailViewController
            
            destinationVC.selectedID = self.selectedID
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageBook")
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidArray[indexPath.row].uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let resuts = try context.fetch(fetchRequest)
                if resuts.count > 0{
                    for i in resuts as! [NSManagedObject]{
                        
                        if let id = i.value(forKey: "id") as? UUID{
                            
                            if id == uuidArray[indexPath.row] {
                                
                                context.delete(i)
                                getData()
                                tableView.reloadData()
                                
                                try context.save()
                                
                                break
                            }
                        }
                    }
                }
            }
            catch {
                print("error")
            }
        }
    }

}

