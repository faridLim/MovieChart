//
//  ListViewController.swift
//  myMovieChart
//
//  Created by 임재헌 on 2021/10/29.
//

import UIKit

class ListViewController : UITableViewController{
    /*
    //튜플 아이템을 가진 배열로 정의된 데이터세트
    var dataset = [
        ("다크 나이트", "영웅물에 철학에 음악까지 더해져 예술이되다.", "2008-09-04", 8.95,"darknight.jpg"),
        ("호우시절","때를 알고 내리는 좋은 비","2009-10-08",7.31,"rain.jpg"),
        ("말할 수 없는 비밀", "여기서 너까지 다섯 걸음", "2015-05-07", 9.19,"secret.jpg")
    ]
    
    
    //테이블 뷰를 구성할 리스트 데이터
    lazy var list : [movieVO] = {
        var datalist = [movieVO]()
        for (title, desc, opendate, rating, thumbnail) in self.dataset{
            let mvo = movieVO()
            mvo.title = title
            mvo.description = desc
            mvo.opendate = opendate
            mvo.rating = rating
            mvo.thumbnail = thumbnail
            datalist.append(mvo)
        }
        return datalist
    }()
     */
    
    //현재까지 읽어온 데이터의 페이지 정보
    var page = 1
    //테이블 뷰를 구성할 리스트 데이터
  lazy  var list = [movieVO]()
    
    
    @IBOutlet var moreBtn: UIButton!
    
    
    //뷰가 처음 메모리에 로드될 때 호출되는 메소드
    override func viewDidLoad() {
        //영화 차트 API를 호출한다.
        self.callMovieAPI()
        
    }
    
    //더 보기 버튼을 눌렀을 때 호출되는 메소드
    @IBAction func more(_ sender: UIButton) {
        // 프로퍼티 page 변수에 1을 추가
        self.page+=1
        //영화차트 API를 호출한다.
        self.callMovieAPI()
        //데이터를 다시 읽어오도록 테이블 뷰를 갱신한다.
        self.tableView.reloadData()
    }
    
    
    //영화 차트 API를 호출해주는 메소드
    func callMovieAPI(){

        //API호출을 위한 URI 생성
        let url = "http://115.68.183.178:2029/hoppin/movies?order=releasedateasc&count=15&page=\(self.page)&version=1&genreId="
        let apiURI : URL! = URL(string: url)
        
        //RestApi를 호출
        let apidata = try! Data(contentsOf: apiURI)
        
        //데이터 전송결과를 로그로 출력
        let log = NSString(data: apidata, encoding: String.Encoding.utf8.rawValue) ?? "데이터가 없습니다."
        NSLog("API Result = \(log)")
        
        //JSon 객체를 파싱하여 NSDictionary 객체로 변환
        do{
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            
            //데이터 구조에 따라 차례대로 캐스팅하여 읽어온다.
            let hoppin = apiDictionary["hoppin"] as! NSDictionary
            let movies = hoppin["movies"] as! NSDictionary
            let movie = movies["movie"] as! NSArray
            
            //Iterator 처리를 하면서 API 데이터를 MovieVO객체에 저장
            for row in movie{
                //태이블 뷰 리스트를 구성할  테이터 형식
                let mvo = movieVO()
                
                //순회 상수를 NSDictionary 타입으로 캐스팅
                let r = row as! NSDictionary
                
                // movie 배열의 각 데이터를 mvo 상수의 속성에 대입
                mvo.title = r["title"] as? String
                mvo.description = r["genreNames"] as? String
                mvo.thumbnail = r["thumbnailImage"] as? String
                mvo.detail = r["linkUrl"] as? String
                mvo.rating = ((r["ratingAverage"] as! NSString).doubleValue)
                
                
                //list배열에 추가
                self.list.append(mvo)
                
                //전체 데이터 카운트를 얻는다.
                let totalCount = (hoppin["totalCount"] as? NSString)!.integerValue
                
                //totalCount가 읽어온 데이터 크기와 같거나 클경우 더보기 버튼을 막는다.
                if(self.list.count >= totalCount){
                    self.moreBtn.isHidden = true
                }
            }
        }catch{
            NSLog("Parse Error!!")
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("선택된 행은 \(indexPath.row) 번째 행입니다.")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        // 주어진 행에 맞는 데이터 소스를 읽어온다.
        let movieData = self.list[indexPath.row]
        //로그출력
        NSLog("제목:\(movieData.title!), 호출된 행번호 :\(indexPath.row)")
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! MovieCell
        //값을 할당
        cell.title?.text = movieData.title
        cell.desc?.text = movieData.description
        cell.opendate?.text = movieData.opendate
        cell.rating?.text = "\(movieData.rating!)"
        
        //** 비동기방식으로 썸네일 이미지를 읽어옴
        DispatchQueue.main.async(execute:{
            NSLog("비동기 방식으로 실행되는 부분입니다.")
            cell.thumbnail.image = self.getThumbnailImage(_index: indexPath.row)
        })
        
        NSLog("메소드 실행을 종료하고 셀을 리턴합니다.")
        return cell
   
        /*  태그로 값변경
        //테이블 셀 객체를 직접 생성하는대신 큐로부터 가져옴
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell")!
        
      
        //영화제목이 표시될 레이블을 호출
        let title = cell.viewWithTag(101) as? UILabel
        //영화요약이 표시될 레이블 호출
        let desc = cell.viewWithTag(102) as? UILabel
        //영화 개봉일이 표시될 레이블 호출
        let opendate = cell.viewWithTag(103) as? UILabel
        //영화 별점이 표시될 레이블
        let rating = cell.viewWithTag(104) as? UILabel
        
        //레이블 변수에 데이터 할당
        title?.text = movieData.title
        desc?.text = movieData.description
        opendate?.text = movieData.opendate
        rating?.text = "\(movieData.rating!)"
        
         return cell
         */
        
    }
    
    //썸네일 이미지를 가져오는 메소드 - 메모이제이션 기법 적용
    func getThumbnailImage(_index : Int) -> UIImage{
        //인자값으로 받은 인덱스를 기반으로 해당하는 배열 데이터를 읽어옴
        let mvo = self.list[_index]
        
        //메모이제이션 : 저장된이미지가 있으면, 그것을 반환하고, 없을 경우 내려 받아 저장 후 반환
        
        if let savedImage = mvo.thumbnailImage{
            return savedImage
        }else{
            let url : URL! = URL(string : mvo.thumbnail!)
            let imageData = try! Data(contentsOf: url)
            mvo.thumbnailImage = UIImage(data: imageData)
            
            return mvo.thumbnailImage! //저장된 이미지를 반환
        }
    }
    
  
    
    
    
}
