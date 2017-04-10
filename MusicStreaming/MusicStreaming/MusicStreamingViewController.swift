//
//  ViewController.swift
//  MusicStreaming
//
//  Created by Priya Xavier on 4/10/17.
//  Copyright © 2017 Copper Mobile. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import MarqueeLabel

class MusicStreamingViewController: UIViewController {
  
  struct radioStation {
    var name = String()
    var streamURL = String()
    var desc = String()
    var imageURL = String()
  }
  
  var player:AVPlayer!
  var playerItem:AVPlayerItem!
  
  var stationsArray = [radioStation]()
  var selectedStation = radioStation(name: "Sub Pop Radio", streamURL: "http://djboyradio.streamguys1.com/sub-pop-records.mp3", desc: "Midsized Record Label", imageURL: "station-sub")
  
  //Outlets
  @IBOutlet weak var stationDesc: UILabel!
  @IBOutlet weak var genreImage: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  
  //Button Actions
  @IBAction func playBtn(_ sender: UIButton) {
    
    player!.volume = 1.0
    player!.play()
    
  }
  
  @IBAction func pauseBtn(_ sender: UIButton) {
    player!.pause()
  }
  
  //Access KVO Metadata of PlayerItem
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    if keyPath != "timedMetadata" { return }
    
    let data = object as! AVPlayerItem
    if data.timedMetadata != nil {
      for item in data.timedMetadata! {
        print("Metadata!!!! \(item.stringValue!)")
        
        if item.stringValue != "" {
          self.stationDesc.text = item.stringValue}
        else {
          self.stationDesc.text = self.selectedStation.desc }
        
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    loadStations()
    self.playerItem = AVPlayerItem(url: URL(string: selectedStation.streamURL)!)
    self.player = AVPlayer(playerItem: self.playerItem!)
    self.playerItem.addObserver(self, forKeyPath: "timedMetadata", options: [.initial, .new], context: nil)

  }
  deinit {
        playerItem.removeObserver(self, forKeyPath: "timedMetadata")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  // Read files from main bundle
  func readFileFromResources(_ fileName: String, fileType: String, encoding: String.Encoding = String.Encoding.utf8) -> String {
    
    let absoluteFilePath = Bundle.main.path(forResource: fileName, ofType: fileType)
    if let absoluteFilePath = absoluteFilePath {
      print(absoluteFilePath)
      if let fileData = try? Data.init(contentsOf: URL(fileURLWithPath: absoluteFilePath)) {
        print(fileData)
        if let fileAsString = NSString(data: fileData, encoding: encoding.rawValue) {
          print(fileAsString)
          return fileAsString as String
        } else {
          print("readFileFromResources failed on: \(fileName). Failed to convert data to String!")
          return  ""
        }
        
      } else {
        print("readFileFromResources failed on: \(fileName). Failed to load any data!")
        return  ""
      }
    }
    
    print("readFileFromResources failed on: \(fileName). File does not exist!")
    return  ""
    
    //    func getDataFromFileWithSuccess(success: (_ data: Data) -> Void) {
    //
    //      if let filePath = Bundle.main.path(forResource: "stations", ofType:"json") {
    //        do {
    //          let data = try NSData(contentsOfFile:filePath,
    //                                options: NSData.ReadingOptions.uncached) as Data
    //         success(data)
    //        } catch {
    //          fatalError()
    //        }
    //      } else {
    //        print("The local JSON file could not be found")
    //      }
    
  }
  
  //Parse station files from JSON data
  func loadStations()  {
    let stationsList =  readFileFromResources("stations", fileType: ".json")
    var stationsJson = JSON.parse(stationsList)
    var stationItem = radioStation()
    for station in stationsJson["station"].arrayValue {
      
      stationItem.name = station["name"].stringValue
      stationItem.streamURL = station["streamURL"].stringValue
      stationItem.desc = station["longDesc"].stringValue
      stationItem.imageURL = station["imageURL"].stringValue
      print(stationItem.name)
      stationsArray.append(stationItem)
      stationItem = radioStation()
      
    }
  }

}

extension MusicStreamingViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    return 1
  }
  
  
  // From UITableViewDataSource protocol.
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    print(stationsArray.count)
    return stationsArray.count
  }
  
  
  // From UITableViewDataSource protocol.
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // This will try to reuse a cell if one can be found. If not, a new cell will be created.
    let cell = tableView.dequeueReusableCell(withIdentifier: "stationTableViewCell", for: indexPath) as! StationTableViewCell
    // Find out what index or row we're building for and use that to fetch the corresponding data.
    let row = indexPath.row
    //
    cell.stationLabel.text = stationsArray[row].name
    
    let pic = stationsArray[row].imageURL
    
    if pic == "" {
      cell.stationImage.image = UIImage(named: "default-station")
    } else {
      cell.stationImage.image = UIImage(named: pic)}
    
    if row % 2 == 0 {
      cell.cellBkg.image = UIImage(named: "cellEvenBkg")
    } else {
      cell.cellBkg.image = UIImage(named: "cellOddBkg")
    }
    
    // Finally, return the cell so it can be placed into the table view.
    return cell
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
    // select station link
    selectedStation = stationsArray[indexPath.row]
    
    // select station image
    let pic = selectedStation.imageURL
    if pic == "" {
      self.genreImage.image = UIImage(named: "albumArt")
    } else {
      self.genreImage.image = UIImage(named: pic)}
    
    
    let cell = tableView.cellForRow(at: indexPath)
    cell?.contentView.backgroundColor = UIColor.darkText
    
    //creating another player item with new station url
    print("Current station url \(selectedStation.streamURL)")
    let asset = AVAsset(url: URL(string: selectedStation.streamURL)!)
    self.playerItem = AVPlayerItem(asset: asset)
    self.player.replaceCurrentItem(with: self.playerItem)
    //self.player = AVPlayer(playerItem: self.playerItem!)
    playerItem.addObserver(self, forKeyPath: "timedMetadata", options: [.initial, .new], context: nil)
  }
  
  //Remove previous observer before selecting next station
  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    
    playerItem.removeObserver(self, forKeyPath: "timedMetadata")
    return true
  }
  
  
  func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    
    let cell = tableView.cellForRow(at: indexPath)
    cell?.contentView.backgroundColor = UIColor.darkText
  }
  
  
  func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    
    let cell = tableView.cellForRow(at: indexPath)
    cell?.contentView.backgroundColor = UIColor.clear
  }
  
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
    return indexPath }
  
  
}
