//
//  DetailViewController.swift
//  myMovieChart
//
//  Created by 임재헌 on 2021/11/24.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var wk: WKWebView?
    var mvo : movieVO?  //목록 화면에서 전달하는 영화정보를 받음
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //WebView 객체의 이벤트를 처리하기위해 delegate 지정
        self.wk?.navigationDelegate = self
        self.wk?.uiDelegate = self
        
        //네비게이션 아이템이 추가되어있을경우, self.navigationItem으로 접근가능
        let navibar = self.navigationItem
        navibar.title = self.mvo?.title
        
        /*
        
        //URLRequest 인스턴스 생성
        guard let urlLink = self.mvo?.detail else{return}
        let url = URL(string: urlLink)
        let req = URLRequest(url : url!)
        
        //loadRequest 메소드를 호출하면서 req를 인자값으로 전달함
        self.wk?.load(req)
        
         */
        
        //예외 처리 적용코드
        if let url = self.mvo?.detail{
            if let urlObj = URL(string: url){
                let req = URLRequest(url:urlObj)
                self.wk?.load(req)
            }else{ //URL 형식이 잘못되었을 경우 예외처리(경고창 형식으로 오류메시지를 표시)
                let alert = UIAlertController(title: "오류", message: "잘못된URL입니다.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "확인", style: .cancel){(_) in
                    //이전 페이지로 되돌려보냄
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }
        } else {//URL 값이 전달되지 않았을 경우에 대한 예외처리(경고창 형식으로 오류메시지를 표시)
            let alert = UIAlertController(title: "오류", message: "필수 파라미터가 누락되었습니다.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "확인", style: .cancel){(_) in
                //이전 페이지로 되돌려보낸다.
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK:- WKNavigationDelegate 프로토콜 구현
extension DetailViewController : WKNavigationDelegate{
    //웹 뷰가 HTML페이지를 읽어 들이기 시작할 때 호출됨
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.spinner.startAnimating() //인디케이터 뷰의 애니메이션을 실행
    }
    //웹 뷰가 HTML페이지를 전부 읽어드렸을 때, 호출
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.spinner.stopAnimating() //인디케이터 뷰의 애니메이션을 중지
    }
    //웹 뷰가 HTML페이지를 불러오는 것을 실패하였을 때, 호출
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating() //인디케이터 뷰의 애니메이션을 중지
        //경고창 형식으로 오류메시지를 표시해준다.
        self.alert(_message : "상세 페이지를 읽어오지 못했습니다."){
            //버튼 클릭시 이전화면으로 돌려보낸다.
            self.navigationController?.popViewController(animated: true)
        }
    }

    //웹 뷰가 네트워크문제로 HTML페이지를 불러오지 못했을때 호출
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating() //인디케이터 뷰의 애니메이션을 중지
        //경고창 형식으로 오류메시지를 표시해준다.
        self.alert(_message : "상세 페이지를 읽어오지 못했습니다."){
            //버튼 클릭시 이전화면으로 돌려보낸다.
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

//MARK:- WKUIDelegate 프로토콜 구현
extension DetailViewController : WKUIDelegate{
}

//MARK:- 심플한 경고창 함수 정의용 extension
extension DetailViewController{
    func alert(_message: String, onClick : (() -> Void)? = nil){
        let controller = UIAlertController(title: nil, message: _message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel){
            (_) in onClick?()
        })
        DispatchQueue.main.async {
            self.present(controller,animated: true)
        }
    }
}

