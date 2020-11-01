//
//  ViewController.swift
//  SwipeTap
//
//  Created by Ted Kim on 2020/10/31.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    let pageSize = 3
    
    // 현재는 밑에 화살표와 시계모양 컨트롤
    lazy var pageControl: UIPageControl = {
        // Create a UIPageControl.
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: self.view.frame.maxY - 100, width: self.view.frame.maxX, height:50))
        // pageControl.backgroundColor = UIColor.clear  -> 실제 구현할때는 클리어컬러로 해야한다.
        pageControl.backgroundColor = UIColor.black
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = .orange
        
        // Set the number of pages to page control.
        pageControl.numberOfPages = pageSize
        
        // Set the current page.
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false


        var indicators: [UIView] = []

        if #available(iOS 14.0, *) {
            indicators = pageControl.subviews.first?.subviews.first?.subviews ?? []
        } else {
            indicators = pageControl.subviews
        }

        for (index, indicator) in indicators.enumerated() {
            let image = pageControl.currentPage == index ? UIImage.init(named: "ArrowRight2") : UIImage.init(named: "timer0")
//            하단 페이지 컨트롤 이곳에 기본사진, 전신사진, 반신사진 안내를 이미지 형태로 넣어준다.
//             삼항 연산자로 표현하면 안될듯, case로 수정해야할듯
            
            
            if let dot = indicator as? UIImageView {
                dot.image = image
            } else {
                let imageView = UIImageView.init(image: image)
                indicator.addSubview(imageView)
                // here you can add some constraints to fix the imageview to his superview
            }
        }
        return pageControl
    }()
    
    //UI 스크롤뷰를 생성
    lazy var scrollView: UIScrollView = {
        // Create a UIScrollView.
        let scrollView = UIScrollView(frame: self.view.frame)
        
        // Hide the vertical and horizontal indicators.
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        // Allow paging.
        scrollView.isPagingEnabled = true
        
        // Set delegate of ScrollView.
        scrollView.delegate = self
        
        // Specify the screen size of the scroll.
        // 스크롤뷰의 사이즈 조정 여기서 다양하게 실험해서 이쁘게 만들것.
        scrollView.contentSize = CGSize(width: CGFloat(pageSize) * self.view.frame.maxX, height: 0)
        
        return scrollView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Set the background color to Cyan.
        // 전체 뷰의 백그라운드 컬러 변경
//        self.view.backgroundColor = .clear
        self.view.backgroundColor = .gray //clear로하면 스와이핑이 안됨. 실제 구현시에는 뷰자체를 클리어로 바꿀것, 코드로하지말고.
        
        // Get the vertical and horizontal sizes of the view.
        let width = self.view.frame.maxX, height = self.view.frame.maxY
        
        // Generate buttons for the number of pages.
        for i in 0 ..< pageSize {
            
            // set UIImageView with a frame size // 사이즈 조절 -> 뷰파인터 크기 대비로 조정해보기
            // 전신: 뷰파인더의 4분의 1지점에 다리 위치, 반신: 뷰 화면의 8분의 1지점에 무릎 위치
            let layoutImage: UIImageView = UIImageView(frame: CGRect(x: CGFloat(i) * width + width/2 - +150, y: height/2 - -100, width: 300, height: 80))
            layoutImage.image = UIImage(named: "GuideLine\(i)") // 기본, 반신, 전신의 가이드 라인을 보여주는 곳/ 화면상 위다!
            scrollView.addSubview(layoutImage)
            
            
            //let 하나더 선언해서
            //scrollView.addSubview(만들었다치고)
            
        }
        
        // Add UIScrollView, UIPageControl on view
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.pageControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //페이지 넘길때 절반이상 넘어가야 다음 페이지로 넘김
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // When the number of scrolls is one page worth.
        if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
            // Switch the location of the page.
            pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.maxX)
            
            // control indicator tint color
            pageControl.currentPageIndicatorTintColor = .orange
            pageControl.pageIndicatorTintColor = .white
        }
    }
}
