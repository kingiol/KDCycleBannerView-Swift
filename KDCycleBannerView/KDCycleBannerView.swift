//
//  KDCycleBannerView.swift
//  KDCycleBannerView-Swift
//
//  Created by Kingiol on 14-6-14.
//  Copyright (c) 2014年 Kingiol. All rights reserved.
//

import UIKit

@objc protocol KDCycleBannerViewDatasource: NSObjectProtocol {
    func numberOfKDCycleBannerView(bannerView: KDCycleBannerView) -> Array<AnyObject>;
    
    func contentModeForImageIndex(index: Int) -> UIViewContentMode
    
    @optional func placeHolderImageOfZeroBanerView() -> UIImage
    
    @optional func placeHolderImageOfBannerView(bannerView: KDCycleBannerView, atIndex: Int) -> UIImage
}

@objc protocol KDCycleBannerViewDelegate: NSObjectProtocol {
    
    @optional func cycleBannerView(bannerView: KDCycleBannerView, didScrollToIndex index: Int)
    
    @optional func cycleBannerView(bannerView: KDCycleBannerView, didSelectedAtIndex index: Int)
    
}

class KDCycleBannerView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var datasource: KDCycleBannerViewDatasource!
    @IBOutlet var delegate: KDCycleBannerViewDelegate?
    
    var continuous: Bool = false // if YES, then bannerview will show like a carousel, default is NO
    var autoPlayTimeInterval: Int = 0 // if autoPlayTimeInterval more than 0, the bannerView will autoplay with autoPlayTimeInterval value space, default is 0

    var scrollView: UIScrollView = UIScrollView()
    var scrollViewBounces: Bool = true
    var pageControl: UIPageControl = UIPageControl()
    var datasourceImages: Array<AnyObject> = Array()
    var currentSelectedPage: Int = 0
    var completeBlock: (() -> ())?
    
    var autoPlayDelay: dispatch_time_t {
        let delay = Double(autoPlayTimeInterval) * Double(NSEC_PER_SEC)
        return dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    func reloadDataWithCompleteBlock(block: () -> ()) {
        completeBlock = block
        setNeedsLayout()
    }
    
    func setCurrentPage(currentPage: Int, animated: Bool) {
        let page = min(datasourceImages.count - 1, max(0, currentPage))
        setSwitchPage(page, animated: animated, withUserInterface: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func didMoveToSuperview() {
        initialize()
        completeBlock?()
    }
    
    func initialize() {
        clipsToBounds = true
        initializeScrollView()
        initializePageControl()
        
        loadData()
        
        // progress autoPlayTimeInterval
        if autoPlayTimeInterval > 0 {
            if (continuous && datasourceImages.count > 3) || (!continuous && datasourceImages.count > 1) {
                dispatch_after(autoPlayDelay, dispatch_get_main_queue(), autoSwitchBanner)
            }
        }
    }
    
    func initializeScrollView() {
        scrollView = UIScrollView(frame: CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)));
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.autoresizingMask = autoresizingMask
        self.addSubview(scrollView)
    }
    
    func initializePageControl() {
        var pageControlFrame: CGRect = CGRect(x: 0, y: 0, width: CGRectGetWidth(scrollView.frame), height: 30)
        pageControl = UIPageControl(frame: pageControlFrame)
        pageControl.center = CGPoint(x: CGRectGetWidth(scrollView.frame) * 0.5, y: CGRectGetHeight(scrollView.frame) - 12)
        pageControl.userInteractionEnabled = false
        self.addSubview(pageControl)
    }
    
    func loadData() {
        datasourceImages = datasource.numberOfKDCycleBannerView(self)
        
        if datasourceImages.count == 0 {
            //显示默认页，无数据页面
            
            if let image = datasource.placeHolderImageOfZeroBanerView?() {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(scrollView.frame), height: CGRectGetHeight(scrollView.frame)))
                imageView.clipsToBounds = true
                imageView.contentMode = .ScaleAspectFill
                imageView.backgroundColor = UIColor.clearColor()
                imageView.image = image
                scrollView.addSubview(imageView)
            }
            
            return
        }
        
        pageControl.numberOfPages = datasourceImages.count
        pageControl.currentPage = 0
        
        if continuous {
            datasourceImages.insert(datasourceImages[datasourceImages.count - 1], atIndex: 0)
            datasourceImages.append(datasourceImages[0])
        }
        
        let contentWidth = CGRectGetWidth(scrollView.frame)
        let contentHeight = CGRectGetHeight(scrollView.frame)
        
        scrollView.contentSize = CGSize(width: contentWidth * CGFloat(datasourceImages.count), height: contentHeight)
        
        for (index, obj: AnyObject) in enumerate(datasourceImages) {
            let imgRect = CGRectMake(contentWidth * CGFloat(index), 0, contentWidth, contentHeight)
            
            let imageView = UIImageView(frame: imgRect)
            imageView.backgroundColor = UIColor.clearColor()
            imageView.clipsToBounds = true
            imageView.contentMode = datasource.contentModeForImageIndex(index)
            
            if obj is UIImage {
                imageView.image = obj as UIImage
            }else if obj is String || obj is NSURL {
                let activityIndicatorView = UIActivityIndicatorView()
                activityIndicatorView.center = CGPointMake(CGRectGetWidth(scrollView.frame) * 0.5, CGRectGetHeight(scrollView.frame) * 0.5)
                activityIndicatorView.tag = 100
                activityIndicatorView.activityIndicatorViewStyle = .WhiteLarge
                activityIndicatorView.startAnimating()
                imageView.addSubview(activityIndicatorView)
                imageView.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old, context: nil)
                
                if let placeHolderImage = datasource.placeHolderImageOfBannerView?(self, atIndex: index) {
                    imageView.setImageWithURL(obj is String ? NSURL(string: obj as String) : obj as NSURL, placeholderImage: placeHolderImage)
                }else {
                    imageView.setImageWithURL(obj is String ? NSURL(string: obj as String) : obj as NSURL)
                }
            }
            scrollView.addSubview(imageView)
        }
        
        if continuous && datasourceImages.count > 1 {
            scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.frame), 0)
        }
        
        // single tap gesture recognizer
        let tapGestureRecognize = UITapGestureRecognizer(target: self, action: Selector("singleTapGestureRecognizer:")) // designated initializer)
        tapGestureRecognize.delegate = self
        tapGestureRecognize.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapGestureRecognize)
    }
    
    func moveToTargetPosition(targetX: CGFloat, withAnimated animated: Bool) {
        scrollView.setContentOffset(CGPointMake(targetX, 0), animated: animated)
    }
    
    func setSwitchPage(switchPage: Int, animated: Bool, withUserInterface userInterface: Bool) {
        var page = -1
        if userInterface {
            page = switchPage
        }else {
            currentSelectedPage++
            page = currentSelectedPage % (continuous ? datasourceImages.count - 1 : datasourceImages.count)
        }
        
        if continuous {
            if datasourceImages.count > 1 {
                if page >= datasourceImages.count - 2 {
                    page = datasourceImages.count - 3
                    currentSelectedPage = 0
                    moveToTargetPosition(CGRectGetWidth(scrollView.frame) * CGFloat(page + 2), withAnimated: animated)
                }else {
                    moveToTargetPosition(CGRectGetWidth(scrollView.frame) * CGFloat(page + 1), withAnimated: animated)
                }
            }else {
                moveToTargetPosition(0, withAnimated: animated)
            }
        }else {
            moveToTargetPosition(CGRectGetWidth(scrollView.frame) * CGFloat(page), withAnimated: animated)
        }
        scrollViewDidScroll(scrollView)
    }
    
    func autoSwitchBanner() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        setSwitchPage(-1, animated: true, withUserInterface: false)
        dispatch_after(autoPlayDelay, dispatch_get_main_queue(), autoSwitchBanner)
    }
    
    //pragma mark - KVO
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: NSDictionary!, context: CMutableVoidPointer)
    {
        if keyPath == "image" {
            let imageView = object as UIImageView
            let activityIndicatorView: UIActivityIndicatorView = imageView.viewWithTag(100) as UIActivityIndicatorView
            activityIndicatorView.removeFromSuperview()
            imageView.removeObserver(self, forKeyPath: "image")
        }
    }
    
    //pragma mark - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        var targetX: CGFloat = scrollView.contentOffset.x
        var item_width = CGRectGetWidth(scrollView.frame)
        
        if continuous && datasourceImages.count >= 3 {
            if targetX >= item_width * CGFloat(datasourceImages.count - 1) {
                targetX = item_width
                scrollView.contentOffset = CGPointMake(targetX, 0)
            }else if targetX <= 0 {
                targetX = item_width * CGFloat(datasourceImages.count - 2)
                scrollView.contentOffset = CGPointMake(targetX, 0)
            }
        }
        
        var page: Int = Int(scrollView.contentOffset.x + item_width * 0.5) / Int(item_width)
        if continuous && datasourceImages.count > 1 {
            page--
            if page >= pageControl.numberOfPages {
                page = 0
            }else if (page < 0) {
                page = pageControl.numberOfPages - 1
            }
        }
        
        currentSelectedPage = page
        
        if page != pageControl.currentPage {
            delegate?.cycleBannerView?(self, didScrollToIndex: page)
        }
        
        pageControl.currentPage = page
    }
    
    func singleTapGestureRecognizer(tapGesture: UITapGestureRecognizer) {
        let page = Int(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame))
        delegate?.cycleBannerView?(self, didSelectedAtIndex: page)
    }
    
}
