//
//  ViewController.swift
//  KDCycleBannerView-Swift
//
//  Created by Kingiol on 14-6-14.
//  Copyright (c) 2014年 Kingiol. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KDCycleBannerViewDatasource, KDCycleBannerViewDelegate, UITextFieldDelegate {
                            
    @IBOutlet var textField : UITextField
    
    @IBOutlet var cycleBannerViewTop : KDCycleBannerView
    var cycleBannerViewBottom: KDCycleBannerView = KDCycleBannerView(frame: CGRectZero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cycleBannerViewTop.datasource = self
        cycleBannerViewTop.delegate = self
        cycleBannerViewTop.continuous = true
        cycleBannerViewTop.autoPlayTimeInterval = 5


        var topRect: CGRect = cycleBannerViewTop.frame
        topRect.origin.y = CGRectGetMaxY(topRect) + 20
        cycleBannerViewBottom = KDCycleBannerView(frame: topRect)
        cycleBannerViewBottom.datasource = self
        cycleBannerViewBottom.delegate = self
        cycleBannerViewBottom.continuous = true
        cycleBannerViewBottom.autoPlayTimeInterval = 5
        self.view.addSubview(cycleBannerViewBottom)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // KDCycleBannerViewDatasource

    func numberOfKDCycleBannerView(bannerView: KDCycleBannerView) -> Array<AnyObject> {
        return [
        UIImage(named: "image1"),
        "http://d.hiphotos.baidu.com/image/w%3D2048/sign=ed59838948ed2e73fce9812cb339a08b/58ee3d6d55fbb2fb9835341f4d4a20a44623dca5.jpg",
        "http://d.hiphotos.baidu.com/image/w%3D2048/sign=5ad7fab780025aafd33279cbcfd5aa64/8601a18b87d6277f15eb8e4f2a381f30e824fcc8.jpg",
        "http://e.hiphotos.baidu.com/image/w%3D2048/sign=df5d0b61cdfc1e17fdbf8b317ea8f703/0bd162d9f2d3572c8d2b20ab8813632763d0c3f8.jpg",
        "http://d.hiphotos.baidu.com/image/w%3D2048/sign=a11d7b94552c11dfded1b823571f63d0/eaf81a4c510fd9f914eee91e272dd42a2934a4c8.jpg"]
    }

    func contentModeForImageIndex(index: Int) -> UIViewContentMode {
        return .ScaleAspectFill
    }
    
    func placeHolderImageOfZeroBanerView() -> UIImage {
        return UIImage(named: "image1")
    }
    
//    func placeHolderImageOfBannerView(bannerView: KDCycleBannerView, atIndex: Int) -> UIImage {
//        return UIImage()
//    }
    
    //  KDCycleBannerViewDelegate
    
    func cycleBannerView(bannerView: KDCycleBannerView, didScrollToIndex index: Int) {
        println("didScrollToIndex:\(index)")
    }
    
    func cycleBannerView(bannerView: KDCycleBannerView, didSelectedAtIndex index: Int) {
        println("didSelectedAtIndex:\(index)")
    }
    
    // UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        let text: String = textField.text
        
        if let page = text.toInt() {
            cycleBannerViewTop.setCurrentPage(page, animated: true)
            cycleBannerViewBottom.setCurrentPage(page, animated: true)
        }
        
        return true
    }
    
}

