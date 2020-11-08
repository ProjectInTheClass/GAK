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

    let settings: [Setting] = [
        Setting(content: "GAK 홈페이지"),
        Setting(content: "GAK 사용법"),
        Setting(content: "개인정보처리방침"),
        Setting(content: "오픈소스 라이선스"),
        Setting(content: "버전: 1.0")
    ]

    // TableViewCell의 header 이미지를 조절
    // 왜 여기선 컬러 리터럴을 못사용하는거지??
    override func viewDidLoad() {
        super.viewDidLoad()

        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        header.backgroundColor = UIColor(displayP3Red: 0.1, green: 0.1, blue: 0.1, alpha: 0.7)
        
        
        let headerLabel = UILabel(frame: header.bounds)
        headerLabel.text = "GAK 환경설정"
        headerLabel.textColor = .white
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.textAlignment = .center
        header.addSubview(headerLabel)
        
        tableView.tableHeaderView = header
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)

        let setting = settings[indexPath.row]
        cell.textLabel?.text = "\(setting.content)"
        
        return cell
    }
    
    // 앱에서 각 셀을 클릭할 시, 정해진 홈페이지로 이동, 깃헙 페이지가 만들어진 후에 주소 변경예정
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        
        case 0:
            if let url = URL(string: "https://codershigh.github.io/WebSite/#/") {
            UIApplication.shared.open(url)
            }
            
        case 1:
            if let url = URL(string: "https://www.notion.so/gaak/b7bb2b4c005b48eb9bc08406116e1041") {
            UIApplication.shared.open(url)
            }
            
        case 2:
            if let url = URL(string: "https://www.notion.so/gaak/Gaak-023f9aefb51747a0807e861ea527b68c") {
            UIApplication.shared.open(url)
            }
            
        case 3:
            if let url = URL(string: "https://www.notion.so/gaak/425cfe05d58f4afdba9e39f3673db926") {
            UIApplication.shared.open(url)
            }
            
        default:
            return
        }
    }
}
