//
//  TutorialMasterVC.swift
//  gaak
//
//  Created by 서인재 on 2020/11/15.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import UIKit
import Foundation

class TutorialMasterVC: UIViewController {
    
    var oldPhone: Bool = false

    var pageVC: UIPageViewController!
    var pageControl: UIPageControl!
    
    var exitBtn: UIButton!
    var exitEverBtn: UIButton!
    
    // Assets
    var contentTitles = ["STEP 1", "STEP 2", "STEP 3", "STEP 4"]
    var contentImages = ["Onboarding_1", "Onboarding_2", "Onboarding_3", "Onboarding_4"]
    var contentImages_oldPhone = ["oldPhone_Onboarding_1", "oldPhone_Onboarding_2", "oldPhone_Onboarding_3", "oldPhone_Onboarding_4"]
    
    override var prefersStatusBarHidden: Bool {
        return true // 아이폰 상단 정보 (시간, 배터리 등)을 숨겨줌
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 종횡비에 따른 기기분류
        oldPhone = self.view.frame.width/self.view.frame.height > 0.5 ? true : false
        
        self.view.backgroundColor = .black
                
        /// page view controller 속성 정의
        pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.dataSource = self
        
        /// page view controller에서 페이지가 될 부분 삽입
        let startTutorial = getContentVC(atIndex: 0) as! TutorialContentsVC
        
        /// 스와이프 할 때마다 이 배열에 하나씩 추가 됨
        pageVC.setViewControllers([startTutorial], direction: .forward, animated: true)
        pageVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        // pageView 컨트롤러를 마스터 뷰 컨트롤러의 자식으로 설정
        /// 3단계 암기할 것
        self.addChild(pageVC)
        self.view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self) // 자식 뷰 컨트롤러에게 부모 뷰 컨트롤러가 바뀌었음을 알림
        
        exitBtn = UIButton()
        exitBtn.setTitle("닫기", for: .normal)
        exitBtn.setTitleColor(.white, for: .normal)
        exitBtn.setTitleColor(.lightGray, for: .selected)
        exitBtn.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 15)
        exitBtn.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        exitBtn.frame = CGRect(x: 40, y: view.frame.height - self.view.safeAreaInsets.bottom - 24, width: 40, height: 20)
        view.addSubview(exitBtn)
        
        exitEverBtn = UIButton()
        exitEverBtn.setTitle("다시보지않기", for: .normal)
        exitEverBtn.setTitleColor(.white, for: .normal)
        exitEverBtn.setTitleColor(.lightGray, for: .selected)
        exitEverBtn.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 15)
        exitEverBtn.addTarget(self, action: #selector(closeEver(_:)), for: .touchUpInside)
        exitEverBtn.frame = CGRect(x: view.frame.width - 120, y: view.frame.height - self.view.safeAreaInsets.bottom - 24, width: 120, height: 20)
        view.addSubview(exitEverBtn)
        
        /// page indicator
        pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.backgroundColor = .clear
    }

    /// 표현하려는 컨텐츠 뷰에 내용을 세팅한 후, DataSource이벤트에서 사용될 뷰컨트롤러 반환
    func getContentVC(atIndex idx: Int) -> UIViewController? {

        // index 범위 체크
        guard self.contentTitles.count > idx && self.contentTitles.count > 0 else {return nil}
        
        let cvc = TutorialContentsVC()

        cvc.imageFile = oldPhone == true ? contentImages_oldPhone[idx] : contentImages[idx]
        cvc.pageIndex = idx
        cvc.view.backgroundColor = .white
        cvc.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-90)
        
        return cvc
    }
    
    /// close and tutorial check
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: false)
    }
    /// close and tutorial check
    @objc func closeEver(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: UserInfoKey.tutorial)
        ud.synchronize()
        self.presentingViewController?.dismiss(animated: false)
    }
}

extension TutorialMasterVC: UIPageViewControllerDataSource {

    // will be appered when "left" swipe the screen
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {return nil}
        
        guard index > 0 else {return nil}
        
        index -= 1 // front page
        
        return self.getContentVC(atIndex: index)
    }
    
    // will be appered when "right" swipe the screen
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard var index = (viewController as! TutorialContentsVC).pageIndex else {return nil}
        
        index += 1 // rear page
        
        guard index < self.contentTitles.count else {return nil}
        
        return self.getContentVC(atIndex: index)
    }
    
    /// 인디 케이터 초기 값
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    /// 인디 케이터에 표시할 페이지 갯수
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentTitles.count
    }
}
