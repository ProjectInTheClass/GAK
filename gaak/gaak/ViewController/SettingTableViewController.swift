//
//  SettingTableViewController.swift
//  gaak
//
//  Created by 서인재 on 2020/11/05.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit
import Foundation


class SettingTableViewController: UITableViewController {

    var settings: [Setting] = [
        Setting(content: "개인정보처리방침"),
        Setting(content: "오픈소스 라이선스"),
        Setting(content: "버전   1.0"),
        Setting(content: "GAK 홈페이지")
    ]
    
    // 내일은 세팅 선언한거 없애고 걍 위에 선언으로 처리해버리자.
    // 왜 여기선 컬러 리터럴을 못사용하는거지??
    // 세팅 화면내에 글씨체 적용도 해야함. sfpro로
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        
        header.backgroundColor = UIColor.lightGray
        //header.backgroundColor = UIColor(displayP3Red: 빨강값, green:초록값, blue:파랑값,alpha: 투명도)
        
        
        let headerLabel = UILabel(frame: header.bounds)
        headerLabel.text = "GAK 옵션"
        headerLabel.textAlignment = .center
        header.addSubview(headerLabel)
        
        tableView.tableHeaderView = header
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return settings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)

        let setting = settings[indexPath.row]
        cell.textLabel?.text = "\(setting.content)"
        
        return cell
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
