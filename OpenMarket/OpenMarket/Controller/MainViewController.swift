//
//  OpenMarket - MainViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class MainViewController: UIViewController {
    @IBOutlet private weak var openMarketCollectionView: UICollectionView!
    @IBOutlet private weak var collectionViewSegment: UISegmentedControl!
    @IBOutlet private weak var myActivityIndicator: UIActivityIndicatorView!

    private let networkHandler = NetworkHandler()
    private var hasNext = true
    private var pageNumber = 1
    
    private var items: [Item] = [] {
        didSet {
            DispatchQueue.main.async {
                self.openMarketCollectionView.reloadData()
            }
        }
    }
    
    private enum CellType: Int {
        case list = 0
        case grid = 1
    }
    
    private var cellType: CellType = .list {
        didSet {
            changeCellType()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openMarketCollectionView.dataSource = self
        openMarketCollectionView.prefetchDataSource = self
        registCell()
        getItemPage()
        setListLayout()
    }
    
    private func registCell() {
        openMarketCollectionView.register(UINib(nibName: "\(ListCell.self)", bundle: nil), forCellWithReuseIdentifier: "\(ListCell.self)")
        openMarketCollectionView.register(UINib(nibName: "\(GridCell.self)", bundle: nil), forCellWithReuseIdentifier: "\(GridCell.self)")
    }
    
    private func getItemPage() {
        let itemPageAPI = ItemPageAPI(pageNumber: pageNumber, itemPerPage: 20)
        networkHandler.request(api: itemPageAPI) { data in
            switch data {
            case .success(let data):
                guard let itemPage = try? DataDecoder.decode(data: data, dataType: ItemPage.self) else { return }
                self.items.append(contentsOf: itemPage.items)
                self.hasNext = itemPage.hasNext
            case .failure(_):
                let alert = UIAlertController(title: "데이터로드 실패", message: "재시도 하시겠습니까?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: .default) {_ in
                    self.getItemPage()
                }
                let noAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
                alert.addAction(noAction)
                alert.addAction(yesAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func changeCellType() {
        if cellType == .list {
            myActivityIndicator.isHidden = false
            myActivityIndicator.startAnimating()
            setListLayout()
            openMarketCollectionView.setListPosition()
        } else {
            myActivityIndicator.isHidden = false
            myActivityIndicator.startAnimating()
            setGridLayout()
            openMarketCollectionView.setGirdPosition()
        }
        openMarketCollectionView.reloadData()
    }
    
    private func setCellComponents(itemCell: ItemCellable, indexPath: IndexPath) {
        let name = self.items[indexPath.row].name
        let price = (self.items[indexPath.row].currency + String(self.items[indexPath.row].price)).strikethrough()
        let isDiscounted = self.items[indexPath.row].discountedPrice == 0 ? false : true
        let bargainPrice = self.items[indexPath.row].currency + String(self.items[indexPath.row].bargainPrice)
        let stock = self.items[indexPath.row].stock == 0 ? "품절" : "잔여수량 : \(self.items[indexPath.row].stock)"
        let stockLabel = self.items[indexPath.row].stock == 0 ?  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1) : #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        let thumnailURL = self.items[indexPath.row].thumbnail
        
        let cellComponents = CellComponents(name: name, price: price, isDiscounted: isDiscounted, bargainPrice: bargainPrice, stock: stock, stockLabelColor: stockLabel, thumbnailURL: thumnailURL)
        
        itemCell.configureCell(components: cellComponents)
        
        self.myActivityIndicator.stopAnimating()
    }
    
    private func moveToAddVC(title: String) {
        guard let addVC = storyboard?.instantiateViewController(withIdentifier: "AddItemViewController") as? AddItemViewController else { return }
        
        addVC.getComponents(title: title)
        
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    @IBAction private func changeLayoutSegment(_ sender: UISegmentedControl) {
        guard let segmentType = CellType(rawValue: sender.selectedSegmentIndex) else { return }
        cellType = segmentType
    }
    
    @IBAction func touchAddButton(_ sender: UIBarButtonItem) {
        moveToAddVC(title: "상품 등록")
    }
}
// MARK: - CollectionView Cell
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cellType == .list {
            guard let listCell = collectionView.dequeueReusableCell(withReuseIdentifier:  "\(ListCell.self)", for: indexPath) as? ListCell else { return ListCell() }
            setCellComponents(itemCell: listCell, indexPath: indexPath)
            return listCell
        } else {
            guard let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(GridCell.self)", for: indexPath) as? GridCell else { return GridCell() }
            setCellComponents(itemCell: gridCell, indexPath: indexPath)
            return gridCell
        }
    }
}

// MARK: - CollectionView Prefetching
extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard hasNext else {
            return
        }
        
        if indexPaths.last?.row == items.count - 1 {
          pageNumber += 1
          getItemPage()
        }
    }
}

// MARK: - CollectionView Layout
extension MainViewController {
    private func setListLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(openMarketCollectionView.frame.height * 0.1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        openMarketCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setGridLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.7))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 7, bottom: 5, trailing: 7)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        
        openMarketCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
}
