//
//  ExporterViewController.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/23/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class ExporterViewController: UIViewController {

    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingLabel.text = "Processing video..."
        progressBar.progress = 0.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ExporterViewController: VideoProgress{
    func updateUI(string: String, progress: Progress?) {
        guard let prog = progress else {return}
        loadingLabel.text = string
        progressBar.progress = Float(prog.fractionCompleted)
        
        if prog.isFinished {
            self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "unwindToDeviceSettingsFromExporter", sender: nil)
        } else if prog.isCancelled{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func giveFeedBack(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        alertVC.view.tintColor = UIColor.black
        present(alertVC, animated: true)
    }
    
    
}
