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

    let ud = UserDefaults.standard

    let settings: [Setting] = [
        Setting(content: "GAK 홈페이지"),
        Setting(content: "GAK 사용법"),
        Setting(content: "개인정보처리방침"),
        Setting(content: "오픈소스 라이선스"),
        Setting(content: "버전: 1.0"),
        Setting(content: "진동(햅틱) On/Off")
    ]
     
    // 스위치 컨트롤 버튼 생성
    lazy var controlSwitch: UISwitch = {
        // Create a Switch.
        let swicth: UISwitch = UISwitch()
        swicth.layer.position = CGPoint(x: 100, y: 0)
        
        // Display the border of Swicth.
        swicth.tintColor = UIColor.orange
        
        // Set Switch to On.
        swicth.isOn = true
        
        // Set the event to be called when switching On / Off of Switch.
        swicth.addTarget(self, action: #selector(onClickSwitch(sender:)), for: UIControl.Event.valueChanged)

        return swicth
    }()
    
    // 스위치 컨트롤 버튼 Action
    @objc func onClickSwitch(sender: UISwitch) {
        // UserDeaults 객체의 인스턴스를 가져온다.
        // 값을 저장한다.
        ud.set(!sender.isOn, forKey: "haptic")
        
        if sender.isOn {
            // Action
        } else {
            // Action
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true // 아이폰 상단 정보 (시간, 배터리 등)을 숨겨줌
    }

    // TableViewCell의 header 이미지를 조절
    override func viewDidLoad() {
        super.viewDidLoad()

        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 45))
        
        header.backgroundColor = UIColor( #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) )
        
        let headerLabel = UILabel(frame: header.bounds)
        headerLabel.text = "GAK 환경설정"
        headerLabel.textColor = .white
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.textAlignment = .center
        header.addSubview(headerLabel)
        
        tableView.tableHeaderView = header
        
        self.view.backgroundColor = .black
    }
    
    // MARK:- View Controller Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        
        if (indexPath.row == 5) {
            
            //controlSwitch.frame = CGRect(
            
            let hapticSwitch: UISwitch = UISwitch()
            hapticSwitch.layer.position = CGPoint(x: cell.frame.maxX - 75, y: cell.frame.height/2)
            
            // Display the border of Swicth.
            hapticSwitch.tintColor = UIColor.orange
            
            // Set Switch to On.
            hapticSwitch.isOn = !ud.bool(forKey: "haptic")
            
            // Set the event to be called when switching On / Off of Switch.
            hapticSwitch.addTarget(self, action: #selector(onClickSwitch(sender:)), for: UIControl.Event.valueChanged)
            
            cell.addSubview(hapticSwitch)

        }
        return cell
    }

//    세션별 헤더는 없는게 더 괜찮은 것 같다.
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return section == 0 ? "[GAK 소개]" : "[GAK 기능설정]"
//    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30.0
//    }

    // 앱에서 각 셀을 클릭할 시, 정해진 홈페이지로 이동, 깃헙 페이지가 만들어진 후에 주소 변경예정
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
//        if indexPath.section == 0{
            switch indexPath.row{
            
            case 0:
                if let url = URL(string: "https://projectintheclass.github.io/GAK/") {
                    UIApplication.shared.open(url)
                }
                
            case 1:
                if let url = URL(string: "https://www.notion.so/gaak/GAK-71bb9a4903dd4f4a8dd78884ca817111") {
                    UIApplication.shared.open(url)
                }
                
            case 2:
                if let url = URL(string: "https://www.notion.so/gaak/be8788e87447493b9f4bc9675908ee40") {
                    UIApplication.shared.open(url)
                }
                
            case 3:
                if let url = URL(string: "https://www.notion.so/gaak/f915f322eaf447f89e593839139e5beb") {
                    UIApplication.shared.open(url)
                }
                
            default:
                return
            }
        }
    }
//}
