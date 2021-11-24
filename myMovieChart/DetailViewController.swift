//
//  DetailViewController.swift
//  myMovieChart
//
//  Created by 임재헌 on 2021/11/24.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet var wk: WKWebView?
    var mvo : movieVO?  //목록 화면에서 전달하는 영화정보를 받음
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //네비게이션 아이템이 추가되어있을경우, self.navigationItem으로 접근가능
        let navibar = self.navigationItem
        navibar.title = self.mvo?.title
        
        //URLRequest 인스턴스 생성
        guard let urlLink = self.mvo?.detail else{return}
        let url = URL(string: urlLink)
        let req = URLRequest(url : url!)
        
        //loadRequest 메소드를 호출하면서 req를 인자값으로 전달함
        self.wk?.load(req)
        
        
    }


}
