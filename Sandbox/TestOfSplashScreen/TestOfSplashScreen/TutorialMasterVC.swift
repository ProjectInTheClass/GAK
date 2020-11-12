//
//  TutorialMasterVC.swift
//  TestOfSplashScreen
//
//  Created by 서인재 on 2020/11/12.
//

import Foundation
import UIKit

class TutorialMasterVC: UIViewController {
    var pageVC: UIPageViewController!
    
    var pageControl: UIPageControl!
    
    var exitBtn: UIButton!
    
    // Assets
    var contentTitles = ["STEP 1", "STEP 2", "STEP 3", "STEP 4"]
    var contentImages = ["page0", "page1", "page2", "page3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// page view controller 속성 정의
        pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.dataSource = self
        
        /// page view controller에서 페이지가 될 부분 삽입
        let startTutorial = getContentVC(atIndex: 0) as! TutorialContentsVC
        
        /// 스와이프 할 때마다 이 배열에 하나씩 추가 됨
        pageVC.setViewControllers([startTutorial], direction: .forward, animated: true)
        pageVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 90)
        
        // pageView 컨트롤러를 마스터 뷰 컨트롤러의 자식으로 설정
        /// 3단계 암기할 것
        self.addChild(pageVC)
        self.view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self) // 자식 뷰 컨트롤러에게 부모 뷰 컨트롤러가 바뀌었음을 알림
        
        exitBtn = UIButton()
        exitBtn.setTitle("close", for: .normal)
        exitBtn.setTitleColor(.blue, for: .normal)
        exitBtn.setTitleColor(.green, for: .selected)
        exitBtn.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        exitBtn.frame = CGRect(x: view.frame.width - 70, y: view.frame.height-30, width: 50, height: 30)
        view.addSubview(exitBtn)
        
        /// page indicator
        pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .blue
        pageControl.backgroundColor = .darkGray
    }

    /// 표현하려는 컨텐츠 뷰에 내용을 세팅한 후, DataSource이벤트에서 사용될 뷰컨트롤러 반환
    func getContentVC(atIndex idx: Int) -> UIViewController? {
        
        // index 범위 체크
        guard self.contentTitles.count > idx && self.contentTitles.count > 0 else {return nil}
        
        let cvc = TutorialContentsVC()
        cvc.titleText = contentTitles[idx]
        cvc.imageFile = contentImages[idx]
        cvc.pageIndex = idx
        cvc.view.backgroundColor = .white
        cvc.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-90)
        return cvc
    }
    
    /// close and tutorial check
    @objc func close(_ sender: Any) {
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
