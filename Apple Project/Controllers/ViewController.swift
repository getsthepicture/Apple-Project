//
//  ViewController.swift
//  Apple Project
//
//  Created by Laurence Wingo on 6/5/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate,  UITableViewDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var downloadedCities = [City]()
    var alphabeticallySortedCities = [City]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadJson()
        alphabeticallySortCities()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //The reasons I decided to use Swift's new codeable protocol to parse the JSON data is because this process is much more simpler and offers the aesthetics of clean code.  If you look at the git history of this project, I initially serialized the JSON using the outdated process which was overfflowing with guard statements ensure each element was present in the JSON.  Also by using codeables, I can adjust the model object more easily.
    func downloadJson(){
        //ensuring we have a vaild path
        //create an if/let or guard statement to silence warning before running
        guard let path = Bundle.main.path(forResource: "cities", ofType: "json") else { return }
        
        let url = URL.init(fileURLWithPath: path)
        
        do {
            let data = try Data.init(contentsOf: url)

            let downloadedPlots = try JSONDecoder().decode([City].self, from: data)
            
            downloadedCities = downloadedPlots
        } catch  {
            print(error)
        }
    }
    
    func alphabeticallySortCities(){
        let sortCitiesAlphabetically = {
            self.downloadedCities.sorted(by: { if $0.name != $1.name {
                return $0.name < $1.name
            } else {
                return $0.country < $1.country
                }})
        }
        alphabeticallySortedCities = sortCitiesAlphabetically()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return alphabeticallySortedCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CitiesCell") as? CitiesTableViewCell else { return UITableViewCell()}
        
        cell.locationLabel.text = "\(alphabeticallySortedCities[indexPath.row].name), \(alphabeticallySortedCities[indexPath.row].country)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "deatilViewController") as? DetailViewController
        
        let selectedCity = alphabeticallySortedCities[indexPath.row]
        vc?.city = selectedCity
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Search Bar
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String){
        guard !searchText.isEmpty else {
            alphabeticallySortedCities = downloadedCities
            tableView.reloadData()
            return
        }
        alphabeticallySortedCities = downloadedCities.filter({ city -> Bool in
            return city.name.hasPrefix(searchText)
        })
       tableView.reloadData()
    }

    
}

