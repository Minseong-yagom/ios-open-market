//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var openMarketCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewSegment: UISegmentedControl!
    let listCellName = String(describing: ListCell.self)
    let gridCellName = String(describing: GridCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registCell()
        setListLayout()
        openMarketCollectionView.dataSource = self
    }
    
    private func registCell() {
        openMarketCollectionView.register(UINib(nibName: listCellName, bundle: nil), forCellWithReuseIdentifier: listCellName)
        openMarketCollectionView.register(UINib(nibName: gridCellName, bundle: nil), forCellWithReuseIdentifier: gridCellName)
    }
    @IBAction func changeLayoutSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setListLayout()
        } else {
            setGridLayout()
        }
        openMarketCollectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionViewSegment.selectedSegmentIndex == 0 {
            guard let listCell = collectionView.dequeueReusableCell(withReuseIdentifier:  listCellName, for: indexPath) as? ListCell else { return ListCell() }
            
            return setListCell(cell: listCell, indexPath: indexPath)
        } else {
            guard let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCellName, for: indexPath) as? GridCell else { return GridCell() }
            
            return setGridCell(cell: gridCell, indexPath: indexPath)
        }
    }
}

extension ViewController {
    func setListLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(openMarketCollectionView.frame.height * 0.1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        openMarketCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    func setGridLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.7))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 7, bottom: 5, trailing: 7)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        
        openMarketCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    func setListCell(cell: ListCell, indexPath: IndexPath) -> ListCell {
        let cell = cell
        cell.layer.borderWidth = 0
        
        return cell
    }
    
    func setGridCell(cell: GridCell, indexPath: IndexPath) -> GridCell {
        let cell = cell
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 1
        
        return cell
    }
}
