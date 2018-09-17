//
//  MasterViewController.swift
//  StanfordFarmApp2018
//
//  Created by Matthew Park on 8/1/18.
//  Copyright © 2018 Matthew Park. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var dashContainer: UIView!
    @IBOutlet weak var bedContainer: UIView!
    
    var bedViewController = BedViewController()
    
    var objects = [Any]()
    var masters = ["DASHBOARD", "BED 1", "BED 2", "BED 3", "BED 4", "BED 5", "BED 6", "BED 7", "BED 8", "BED 9", "BED 10", "BED 11", "BED 12", "BED 13", "BED 14", "BED 15"]
    var selectedCell = 0
    
    var data:[String:[String:AnyObject]]! = [:]
    var G1:[Int]! = []
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
        bedContainer.isHidden = true
        
        firebaseGet()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.mainTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
    }
    
    func firebaseGet() {
        // Firebase GET request
        self.ref = Database.database().reference()
        
        ref.child("Live").observe(DataEventType.childAdded, with: { (snapshot) in
            let key = snapshot.key
            let item = snapshot.value as! [String:AnyObject]
            self.data[key] = item
            
            DispatchQueue.main.async() {
                self.mainTableView.reloadData()
            }
        })
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bedEmbed" {
            if let bedViewController = segue.destination as? BedViewController {
                self.bedViewController = bedViewController
            }
        }
        
//        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                print("segued")
//                let title = masters[indexPath.row]
//
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//
//                controller.isBed = indexPath.row==0 ? false : true
//                controller.detailItem = title
//                controller.data = data
//            }
//        }
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "masterCell", for: indexPath) as! MasterTableViewCell

        let title = masters[indexPath.row]
        cell.mainTitle!.text = title
        
        if indexPath.row == 0 {
            cell.mainImage.image = UIImage(named: "dashboard")
        } else {
            cell.mainImage.image = UIImage(named: "bed")
        }
        
        cell.mainImage.setImageColor(color: UIColor.white)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedCell {
            selectedCell = indexPath.row
            if indexPath.row > 0 {
                if bedContainer.isHidden {
                    switchContainers()
                }
                self.bedViewController.bedNo = indexPath.row
                self.bedViewController.hideEndConfirm = true
            } else if indexPath.row == 0 && dashContainer.isHidden {
                switchContainers()
            }
        }
    }
    
    func switchContainers() {
        dashContainer.isHidden = !dashContainer.isHidden
        bedContainer.isHidden = !bedContainer.isHidden
    }
}

