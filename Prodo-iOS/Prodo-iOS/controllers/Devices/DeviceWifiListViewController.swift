//
//  DeviceWifiListViewController.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/20/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class DeviceWifiListViewController: UIViewController {

    
    var device: String?
    var store: Store?
    var wifiNetworkList = [String]()
    @IBOutlet weak var tableView: UITableView!
    var ssid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAvailableNetworks()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getAvailableNetworks), name: Notification.Name("ConnectedToProdoWifi"), object: nil)
        
        performSegue(withIdentifier: "demoJump", sender: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelWasPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToDevicesFromWifiSettings", sender: nil)
    }
    
    @objc func getAvailableNetworks(){
        
        if let url = URL(string:"http://192.168.4.1/ssid" ) {
            print(url)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                guard let response = response,
                    let data = data
                    else {return}
                
                do {
                    let ssid = try JSONDecoder().decode(Ssid.self, from: data)
                    self.wifiNetworkList = ssid.ssids
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                catch  {
                    print(error)
                }
            }).resume()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func unwindToWifiSelection(segue:UIStoryboardSegue) {
        tableView.reloadData()
    }
    

}

extension DeviceWifiListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wifi_cell", for: indexPath)
        cell.textLabel?.text = wifiNetworkList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wifiNetworkList.count // your number of cell here
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ssid = wifiNetworkList[indexPath.row]
        performSegue(withIdentifier: "goToWifiPassword", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NetworkPasswordViewController {
            destination.ssid = ssid
            destination.store = store
        } else if let destination = segue.destination as? DeviceKeyViewController {
            destination.store = self.store
        }
    }
}
