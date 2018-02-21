//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Daniel Yang on 2018-02-21.
//  Copyright © 2018 Daniel Yang. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "7529f3d55e356ec0433518174e8f9665"

    var coordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var lblResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Weather"
        
        // Get weather from coordinate
        getWeather()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Functions
    
    func getWeather() {
        // Get weather data using OpenWeatherMap APIs
        if CLLocationCoordinate2DIsValid(self.coordinate!) {
            let cordString = "{\(String(format: "%f", (self.coordinate?.latitude)!)),\(String(format: "%f", (self.coordinate?.longitude)!))}"
            
            // Check network connection
            if !Reachability.isConnectedToNetwork() {
                // Network not available
                
                // Load cached weather data
                if let weather = UserDefaults.standard.value(forKey: cordString) as? String {
                    self.lblResult.text = weather
                } else {
                    self.lblResult.text = "No cached data"
                }
                
            } else {
                // Network available
                let session = URLSession.shared
                
                let weatherURL = URL(string: "\(openWeatherMapBaseURL)?lat=\(String(format: "%f", (self.coordinate?.latitude)!))&lon=\(String(format: "%f", (self.coordinate?.longitude)!))&APPID=\(openWeatherMapAPIKey)")!
                print(weatherURL.absoluteString)
                
                let dataTask = session.dataTask(with: weatherURL) {
                    (data: Data?, response: URLResponse?, error: Error?) in
                    
                    if let error = error {
                        print("Error:\n\(error)")
                    } else {
                        if let data = data {
                            
                            let dataString = String(data: data, encoding: String.Encoding.utf8)
                            print("All the weather data:\n\(dataString!)")
                            
                            // Cache data locally
                            UserDefaults.standard.set(dataString, forKey: cordString)
                            
                            DispatchQueue.main.async {
                                self.lblResult.text = dataString
                            }
                            
                            // TO DO: - Convert string to JSON and show data in proper format
                            //                        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                            //
                            //                            if let mainDictionary = jsonObj!.value(forKey: "main") as? NSDictionary {
                            //                                if let temperature = mainDictionary.value(forKey: "temp") {
                            //                                    DispatchQueue.main.async {
                            //
                            //                                    }
                            //                                }
                            //                            } else {
                            //                                print("Error: unable to find temperature in dictionary")
                            //                            }
                            //                        } else {
                            //                            print("Error: unable to convert json data")
                            //                        }
                        } else {
                            print("Error: did not receive data")
                        }
                    }
                }
                
                dataTask.resume()
            }
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
