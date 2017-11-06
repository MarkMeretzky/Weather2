//
//  TableViewController.swift
//  Weather
//
//  Created by Mark Meretzky on 10/27/17.
//  Copyright © 2017 NYU School of Professional Studies. All rights reserved.
//

import UIKit

//The struct holds the information the model needs for a given day.

struct Day {
    let dateTimeISO: String;
    let icon: String;   //filename, including .png
    let minTempF: Int;
    let maxTempF: Int;
    let minTempC: Int;
    let maxTempC: Int;
};

class TableViewController: UITableViewController {
    let cellReuseIdentifier: String = "weather";
    var model: [Day] = [];
    var fahrenheit: Bool = true;  //toggle display between fahrenheit/celsius
    
    required init() {
        super.init(nibName: nil, bundle: nil);
        
        //button to toggle Fahrenheit/Celsius
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "F°/C°",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(toggle));
        
        let id: String = "5ZBNUuaFj9CP6QqQWZybB";
        let secret: String = "UXFJ7VmFStXCExgnMaRPdIMBj5ll3BaKNs8Ml5va";
        let urlString: String = "http://api.aerisapi.com/forecasts/11101?client_id=\(id)&client_secret=\(secret)";
        
        guard let url: URL = URL(string: urlString) else {
            print("could not create URL");
            return;
        }
        
        let sharedSession: URLSession = URLSession.shared;
        
        let downloadTask: URLSessionDownloadTask = sharedSession.downloadTask(
            with: url,
            completionHandler: {(filename: URL?, response: URLResponse?, error: Error?) in
                
                if (error != nil) {
                    print("could not download data from server: \(error!)");
                    return;
                }
                
                //Arrive here when the data from the forecast server has been
                //downloaded into a file in the iPhone.
                
                //Copy the data from the file into a Data object.
                let data: Data;
                do {
                    try data = Data(contentsOf: filename!);
                } catch {
                    print("could not create Data object");
                    return;
                }
                
                //The data is in JSON format.
                //Copy the data from the Data object into a big Swift dictionary.
                let dictionary: [String: Any];
                do {
                    try dictionary = JSONSerialization.jsonObject(with: data) as! [String: Any];
                } catch {
                    print("could not create big dictionary: \(error)");
                    return;
                }
                
                guard let response: [Any] = dictionary["response"]! as? [Any] else {
                    print("could not get array of responses");
                    return;
                }
    
                guard let dict: [String: Any] = response[0] as? [String: Any] else {
            		print("could not get first response");
                    return;
                }
    
                guard let arrayOfDays: [[String: Any]] = dict["periods"] as? [[String: Any]] else {
                    print("could not get array of days");
                    return;
                }
                
                for day in arrayOfDays {
                    guard let dateTimeISO: String = day["dateTimeISO"]! as? String else {
                        print("could not get date for day \(arrayOfDays)");
                        return;
                    }
                    
                    guard let icon: String = day["icon"]! as? String else {
                        print("could not get icon for day \(arrayOfDays)");
                        return;
                    }
                    
                    guard let minTempF: Int = day["minTempF"]! as? Int else {
                        print("could not get minTempF for day \(arrayOfDays)");
                        return;
                    }
                    
                    guard let maxTempF: Int = day["maxTempF"]! as? Int else {
                        print("could not get maxTempF for day \(arrayOfDays)");
                        return;
                    }
                    
                    guard let minTempC: Int = day["minTempC"]! as? Int else {
                        print("could not get minTempC for day \(arrayOfDays)");
                        return;
                    }
                    
                    guard let maxTempC: Int = day["maxTempC"]! as? Int else {
                        print("could not get maxTempC for day \(arrayOfDays)");
                        return;
                    }
                    
                    let day: Day = Day(
                        dateTimeISO: dateTimeISO,
                        icon: icon,
                        minTempF: minTempF,
                        maxTempF: maxTempF,
                        minTempC: minTempC,
                        maxTempC: maxTempC
                    );
                    self.model.append(day);
                }
                
                DispatchQueue.main.async(execute: {() -> Void in
                    self.tableView.reloadData();
                });
 
        });
        
        downloadTask.resume();
    }
    
    //not called
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!;
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier);

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        // Configure the cell...
        let day: Day = model[indexPath.row];
        
        //Display only the date, not the time.
        let date: String = day.dateTimeISO;
        let tloc = date.index(of: "T")!
        cell.textLabel!.text = String(date[..<tloc]);
        
        //Display the icon.
        let iconName: String = day.icon;
        cell.imageView!.image = UIImage(named: iconName);    //nil if .png file doesn't exist
        
        if fahrenheit {
            cell.detailTextLabel!.text = "Hi: \(day.maxTempF)°F    Lo: \(day.minTempF)°F";
        } else {
            cell.detailTextLabel!.text = "Hi: \(day.maxTempC)°C    Lo: \(day.minTempC)°C";
        }
        return cell;
    }
    
    //Called when right bar button is pressed to toggle Fahrenheit/Celsius.

    @objc func toggle() {
        fahrenheit = !fahrenheit;
        tableView.reloadData();
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
