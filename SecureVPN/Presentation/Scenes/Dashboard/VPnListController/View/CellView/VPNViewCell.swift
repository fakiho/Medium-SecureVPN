//
//  VPNViewCell.swift
//  VPN Guard
//
//  Created by Ali Fakih on 5/6/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit

class VPNViewCell: UITableViewCell {

    var pinger: SwiftyPing?
    var configuration: Server? {
        didSet {
            configureData()
        }
    }
    
    var operationQueue: OperationQueue? { willSet {operationQueue?.cancelAllOperations()} }
    @IBOutlet weak var pingLabel: UILabel! {
        didSet {
            pingLabel.font = Fonts.smallFont
        }
    }
    
    static let identifier = String(describing: VPNViewCell.self)
    
    @IBOutlet weak var flagImageView: UIImageView! {
        didSet {
            flagImageView.clipsToBounds = true
            flagImageView.layer.cornerRadius = flagImageView.layer.bounds.width / 2
        }
    }
    
    @IBOutlet weak var starImageView: UIImageView!
    
    @IBOutlet weak var serverNameLabel: UILabel! {
        didSet {
            serverNameLabel.font = Fonts.mediumFont
            serverNameLabel.textColor = Colors.white
        }
    }

    @IBOutlet weak var proLabel: UILabel! {
        didSet {
            proLabel.font = Fonts.boldFont
            proLabel.textColor = Colors.lightBlue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillWith(configuration: Server) {
        self.configuration = configuration
    }
    
    private func configureData() {
        //pinger?.observer = nil
        guard let configuration = configuration else { return }
        self.serverNameLabel.text = configuration.serverDescription
        self.starImageView.isHidden = !(configuration.top == true)
        //self.proLabel.isHidden = !configuration.pro
        downloadImage(from: URL(string: AppConfiguration().flagApi + configuration.country)!)
        //self.flagImageView.image = Images.defaultImage(name: configuration.country, with: .alwaysOriginal)
       
        pinger = try? SwiftyPing(host: configuration.server, configuration: PingConfiguration(interval: 1, with: 3), queue: DispatchQueue.global(qos: .background))
        
        pinger?.observer = { (response) in
           let duration = response.duration
            DispatchQueue.main.async {
                self.colorPingLabel(latency: duration * 1000)
                print(duration)
            }
        }

        pinger?.startPinging()
        pinger?.targetCount = 1
    }
    
    func colorPingLabel(latency: Double) {
        pinger?.stopPinging()
        pingLabel.text = "\(String(format: "%.0f", latency)) ms"
        if case 0 ... 250 = latency {
            pingLabel.textColor = Colors.greenColor
            return
        }
        if case 251 ... 350 = latency {
            pingLabel.textColor = Colors.yellowColor
            return
        } else {
            pingLabel.textColor = Colors.redColor
        }
    }
    
    deinit {
        pinger?.stopPinging()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
         URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
     }
     
     func downloadImage(from url: URL) {
        DispatchQueue.global(qos: .background).async {
            print("Download Started")
            self.getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                DispatchQueue.main.async { [weak self] in
                    self?.flagImageView.image = UIImage(data: data)
                }
            }
        }
     }
}
