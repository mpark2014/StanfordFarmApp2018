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
    var selectedTableViewCell = MasterTableViewCell()
    
    var objects = [Any]()
    var masters = ["DASH", "BED 1", "BED 2", "BED 3", "BED 4", "BED 5", "BED 6", "BED 7", "BED 8", "BED 9", "BED 10", "BED 11", "BED 12", "BED 13", "BED 14", "BED 15"]
    var selectedCell = 0
    
    var data:[String:[String:AnyObject]]! = [:]
    var G1:[Int]! = []
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "DASHBOARD"
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        bedContainer.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
        selectedTableViewCell = self.mainTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! MasterTableViewCell
        selectedTableViewCell.mainImage.setImageColor(color: UIColor.lightGray)
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bedEmbed" {
            if let bedViewController = segue.destination as? BedViewController {
                self.bedViewController = bedViewController
            }
        }
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
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor.groupTableViewBackground
        cell.selectedBackgroundView = bgView
        cell.mainTitle!.highlightedTextColor = UIColor.lightGray
        cell.mainTitle!.textColor = UIColor.white
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
            selectedTableViewCell.mainImage.setImageColor(color: UIColor.white)
            selectedTableViewCell = tableView.cellForRow(at: indexPath) as! MasterTableViewCell
            selectedTableViewCell.mainImage.setImageColor(color: UIColor.lightGray)
            selectedCell = indexPath.row
            
            if indexPath.row > 0 {
                if bedContainer.isHidden {
                    switchContainers()
                }
                self.title = "BED \(indexPath.row)"
                self.bedViewController.bedNo = indexPath.row
                self.bedViewController.hideEndConfirm = true
            } else if indexPath.row == 0 && dashContainer.isHidden {
                self.title = "DASHBOARD"
                switchContainers()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.height+1)/8
    }
    
    func switchContainers() {
        dashContainer.isHidden = !dashContainer.isHidden
        bedContainer.isHidden = !bedContainer.isHidden
    }
}

