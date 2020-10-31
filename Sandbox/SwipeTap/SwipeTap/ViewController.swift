//
//  ViewController.swift
//  SwipeTap
//
//  Created by Ted Kim on 2020/10/31.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    let pageSize = 3
    
    lazy var pageControl: UIPageControl = {
        // Create a UIPageControl.
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: self.view.frame.maxY - 100, width: self.view.frame.maxX, height:50))
        pageControl.backgroundColor = UIColor.orange
        
        // Set the number of pages to page control.
        pageControl.numberOfPages = pageSize
        
        // Set the current page.
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false

        ///
        var indicators: [UIView] = []

        if #available(iOS 14.0, *) {
            indicators = pageControl.subviews.first?.subviews.first?.subviews ?? []
        } else {
            indicators = pageControl.subviews
        }

        for (index, indicator) in indicators.enumerated() {
            let image = pageControl.currentPage == index ? UIImage.init(named: "normal.png") : UIImage.init(named: "selected.png")
            
            if let dot = indicator as? UIImageView {
                dot.image = image
            } else {
                let imageView = UIImageView.init(image: image)
                indicator.addSubview(imageView)
                // here you can add some constraints to fix the imageview to his superview
            }
        }
        ///
        
        return pageControl
    }()
    
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
        scrollView.contentSize = CGSize(width: CGFloat(pageSize) * self.view.frame.maxX, height: 0)
        
        return scrollView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Set the background color to Cyan.
        self.view.backgroundColor = .green
        
        // Get the vertical and horizontal sizes of the view.
        let width = self.view.frame.maxX, height = self.view.frame.maxY
        
        // Generate buttons for the number of pages.
        for i in 0 ..< pageSize {
            
            // set UIImageView with a frame size
            let layoutImage: UIImageView = UIImageView(frame: CGRect(x: CGFloat(i) * width + width/2 - 40, y: height/2 - 40, width: 80, height: 80))
            layoutImage.image = UIImage(named: "layout\(i)")
            scrollView.addSubview(layoutImage)
            
        }
        
        // Add UIScrollView, UIPageControl on view
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.pageControl)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // When the number of scrolls is one page worth.
        if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
            // Switch the location of the page.
            pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.maxX)
        }
    }
    
}
