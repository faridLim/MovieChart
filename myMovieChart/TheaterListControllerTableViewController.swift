//
//  TheaterListControllerTableViewController.swift
//  myMovieChart
//
//  Created by 임재헌 on 2021/11/26.
//

import UIKit

class TheaterListControllerTableViewController: UITableViewController {
    //API를 통해 불러온 데이터를 저장할 배열 변수
    var list = [NSDictionary]()
    
    //읽어올 데이터의 시작위치
    var startPoint : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callTheaterAPI()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //self.list 배열에서 행에 맞는 데이터를 꺼냄
        let obj = self.list[indexPath.row]
        
        //재사용 큐로부터 tCell 식별마제 맞는 셀 객체를 가져옴
        let cell = tableView.dequeueReusableCell(withIdentifier: "tCell") as? TheaterCell
        cell?.name?.text = obj["상영관명"] as? String
        cell?.tel?.text = obj["연락처"] as? String
        cell?.addr?.text = obj["소재지도로명주소"] as? String
        
        cell?.name?.numberOfLines = 0
        cell?.tel?.numberOfLines = 0
        cell?.addr?.numberOfLines = 0
        
        NSLog("상영관:\(obj["상영관명"] as! String), 호출된 행번호 :\(indexPath.row)")
        
        return cell!
    }
    @IBAction func more(_ sender: UIButton) {
        self.callTheaterAPI()
        self.tableView.reloadData()
    }
    //API로부터 극장 정보를 읽어오는 메소드
    func callTheaterAPI(){
        let requestURI = "http://115.68.183.178:2029/theater/list" //API 요청주소
        let sList = 100 //불러올 데이터 개수
        let type = "json" //데이터형식
        
        let urlObj = URL(string: "\(requestURI)?s_page=\(self.startPoint)&s_list=\(sList)&type=\(type)")
        
        do{
            //NSString 객체를 이용하여 API호출 (EUC-KR로 인코딩된 데이터를 읽어오기 위함)
            let stringdata = try NSString(contentsOf: urlObj!, encoding: 0x80_000_422)
            NSLog("API Result = \(stringdata)")
            
            //문자열로 받은 데이터를 UTF-8로 인코딩처리한 Data로 변환
            let encodata = stringdata.data(using: String.Encoding.utf8.rawValue)
            
            do{
            
                //Data 객체를 파싱하여 NSArray 객체로 변환
                let apiArray = try JSONSerialization.jsonObject(with: encodata!, options: []) as? NSArray
                
                //읽어온 데이터를 순회하면서 self.list 배열에 추가
                for obj in apiArray!{
                    self.list.append(obj as! NSDictionary)
                }
            }catch{
                //객체 변환에 실패할경우 (경고창 형식으로 오류메시지 표시)
                let alert = UIAlertController(title: "실패", message: "파싱에 실패하였습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self.present(alert,animated: false)
            }
            //읽어와 할 다음페이지의 시작위치를 알려줌
            self.startPoint += sList
        }catch{
            //API호출에 실패할경우 경고창 형식으로 오류메시지를 표시
            let alert = UIAlertController(title: "실패", message: "데이터를 불러오는 데 실패하였습니다", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            self.present(alert,animated: false)
        }
        
    }
    
}

extension TheaterListControllerTableViewController{
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableView.automaticDimension
    }
}
extension TheaterListControllerTableViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_map"{
            //선택된 셀의 행 정보
            let path = self.tableView.indexPath(for: sender as! UITableViewCell)
            //선택된 셀에 사용된 데이터
            let data = self.list[path!.row]
            //해당 데이터를 segeway객체를 이용해 전달
            (segue.destination as? TheaterViewController)?.theaterData = data
        }
    }
}
