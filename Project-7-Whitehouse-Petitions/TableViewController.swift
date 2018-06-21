//
//  ViewController.swift
//  Project-7-Whitehouse-Petitions
//
//  Created by verebes on 19/06/2018.
//  Copyright © 2018 A&D Progress. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var petitions = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(downloadPetitions), with: nil)
        
    }
    
    //MARK:- Get petitions from Whitehouse
    @objc func downloadPetitions(){
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0{
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        if let url = URL(string: urlString) {
            if let data = try? String(contentsOf: url) {
                let json = JSON(parseJSON: data)
                
                if json["metadata"]["responseInfo"]["status"].intValue == 200 {
                    //we can parse the JSON
                    parse(json)
                    return
                }
            }
        }
        //the error message only shows if any of the conditions will fail and we will not get to parse and return
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        
    }
    
    @objc func showError(){
        DispatchQueue.main.async { [unowned self] in
            let ac = UIAlertController(title: "Loading error", message: "There was an error loading the feed plese check your internet connection and try again later.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }

    }
    
    //MARK:- JSON Parsing
    
    func parse(_ json: JSON){
        for result in json["results"].arrayValue {
            let title = result["title"].stringValue
            let body = result["body"].stringValue
            let sigs = result["signatureCount"].stringValue
            let obj = ["title": title, "body": body, "sigs": sigs]
            petitions.append(obj)
        }
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }

    //MARK:- TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition["title"]
        cell.detailTextLabel?.text = petition["body"]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }


}

