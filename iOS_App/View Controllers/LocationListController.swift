//
//  LocationListController
//  Wait-Times
//
//  Created by Brian Thompson on 1/2/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class LocationListController: UITableViewController, UISearchBarDelegate {
    var categoryIndex = 0
    var categories = ["Restaurants", "Bars", "Libraries", "Dining Halls", "Gyms"]
    var searchBarFrame: CGRect!
    
    //holds the venue name
    var locations: NSMutableArray = []
    var filteredLocations: NSMutableArray = []
    
    //entries contains main metrics like wait times or busy ratings, covers is just for bars
    var entries: NSMutableArray = []
    var covers: NSMutableArray = []
    var ratings: NSMutableArray = []
    
    //filtered versions of main arrays
    var filteredEntries: NSMutableArray = []
    var filteredCovers: NSMutableArray = []
    var filteredRatings: NSMutableArray = []
    
    //Search bar variables
    @IBOutlet weak var searchBar: UISearchBar!
    var isSearching = false
    
    var ref = Database.database().reference()
    var category: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        category = categories[categoryIndex]
        self.title = category
        
        //Setup search bar
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.barTintColor = UIColor(red: 0.23, green: 0.44, blue: 1, alpha: 1.0)
        searchBarFrame = searchBar.frame
        searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBar.frame.origin.y, width: searchBar.frame.width, height: 0)

        //Setup magnifying glass in nav bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
        
        //Setup nib for custom cells
        var nib = UINib(nibName: "CategoryTableViewCell", bundle: nil)
        if(category == "Bars"){
            nib = UINib(nibName: "EntryTwoRowTableViewBarCell", bundle: nil)
        }
        tableView.register(nib, forCellReuseIdentifier: "CategoriesCell")
        
        //Setup top label nib
        let topNib = UINib(nibName: "TwoRowTopLabelTableViewCell", bundle: nil)
        tableView.register(topNib, forCellReuseIdentifier: "TopLabelCell")
        fetchLocations()
    }

    @objc func searchTapped() {
        //Hide magnifying glass
        self.navigationItem.rightBarButtonItem = nil
        
        //Remove shadow from nav bar
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
        self.searchBar.frame = self.searchBarFrame
        
        //Add shadows to searchBar
        self.searchBar.layer.shadowColor = UIColor.black.cgColor
        self.searchBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.searchBar.layer.shadowRadius = 4.0
        self.searchBar.layer.shadowOpacity = 1.0
        self.searchBar.layer.masksToBounds = false
        self.searchBar.isTranslucent = false
        self.tableView.reloadData()
    
        //Show keyboard
        self.searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBar.frame.origin.y, width: searchBar.frame.width, height: 0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
        searchBar.text = ""
        isSearching = false
        self.tableView.reloadData()
    }
    
    func initLists(){
        locations = []
        entries = []
        covers = []
        ratings = []
    }
    
    //Populate the locations array from the database
    func fetchLocations(){
        ref.child("Categories").child(category).observe(.value) { (snapshot) in
            self.initLists()
            // Get user value
            let venue = snapshot.value as? NSDictionary
            for (name, value) in venue! {
                let data = value as! NSDictionary
                self.locations.add(name)
                if(self.category == "Bars"){
                    let cover = data["Most Frequent Cover"] as! String
                    if(cover == "N/A"){
                        self.covers.add(cover)
                    } else {
                        self.covers.add("$" + cover)
                    }
                    let waitTime = data["Average Wait Time"] as! String
                    if(waitTime == "N/A"){
                        self.entries.add(waitTime)
                    } else {
                        self.entries.add(waitTime+" mins")
                    }
                    let rating = data["Average Rating"] as! String
                    self.ratings.add(rating)
                } else if(self.category == "Restaurants"){
                    let waitTime = data["Average Wait Time"] as! String
                    if(waitTime == "N/A"){
                        self.entries.add(waitTime)
                    } else {
                        self.entries.add(waitTime+" mins")
                    }
                } else {
                    let busyRating = data["Average Busy Rating"] as! String
                    if(busyRating == "N/A"){
                        self.entries.add(busyRating)
                    } else {
                        self.entries.add(busyRating+"/10")
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        if isSearching {
            numRows = filteredLocations.count
        } else {
            numRows = locations.count
        }
        
        if categoryIndex == 1 {
            numRows += 1
        }
        return numRows
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if categoryIndex == 1 && indexPath.row == 0 {
            return 25
        }
        return 85
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        var displayedLocations = locations
        if isSearching {
            displayedLocations = filteredLocations
        }
        switch categoryIndex {
            case 0:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? RestaurantController {
                    if let navigator = navigationController {
                        viewController.name = displayedLocations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 1:
                if indexPath.row > 0 {
                    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? BarController {
                        if let navigator = navigationController {
                            viewController.name = displayedLocations[indexPath.row - 1] as! String
                            navigator.pushViewController(viewController, animated: true)
                        }
                    }
                }
            case 2:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? LibraryController {
                    if let navigator = navigationController {
                        viewController.name = displayedLocations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 3:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? DiningHallController {
                    if let navigator = navigationController {
                        viewController.name = displayedLocations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 4:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? GymController {
                    if let navigator = navigationController {
                        viewController.name = displayedLocations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var displayLocations = locations
        var displayEntries = entries
        var displayCovers = covers
        var displayRatings = ratings
        
        if isSearching {
            displayLocations = filteredLocations
            displayEntries = filteredEntries
            displayCovers = filteredCovers
            displayRatings = filteredRatings
            
        }
        if(category == "Bars"){
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopLabelCell", for: indexPath) as! TwoRowTopLabelTableViewCell
                cell.firstInfoLabel.text = "wait time"
                cell.secondInfoLabel.text = "cover"
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! EntryTwoRowTableViewBarCell
            cell.mainLabel.text = displayLocations[indexPath.row - 1] as? String
            cell.firstInfoLabel.text = "\(displayEntries[indexPath.row - 1])"
            cell.secondInfoLabel.text = "\(displayCovers[indexPath.row - 1])"
            cell.rating.rating = Double(displayRatings[indexPath.row - 1] as! String)!
            return cell
        } else if(category == "Restaurants"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoryTableViewCell
            cell.mainLabel.text = displayLocations[indexPath.row] as? String
            cell.infoLabel.text = "(\(displayEntries[indexPath.row]))"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoryTableViewCell
            cell.mainLabel.text = displayLocations[indexPath.row] as? String
            cell.infoLabel.text = "(\(displayEntries[indexPath.row]))"
            return cell
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
        } else {
            isSearching = true
            filteredLocations = []
            filteredEntries = []
            filteredCovers = []
            filteredRatings = []
            for i in 0..<locations.count {
                let location = locations[i] as! String
                if location.lowercased().range(of: searchBar.text!.lowercased()) != nil{
                    filteredLocations.add(location)
                    filteredEntries.add(entries[i])
                    if covers.count > 0 { //We are at a bar
                        filteredCovers.add(covers[i])
                        filteredRatings.add(ratings[i])
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
