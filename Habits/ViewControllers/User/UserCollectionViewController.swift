//
//  UserCollectionViewController.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-10.
//

import UIKit

private let reuseIdentifier = "Cell"

class UserCollectionViewController: UICollectionViewController {
    
    var dataSource: DataSourceType!
    var model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        update()
    }
    
    func update() {
        UserRequest().send {
            switch $0 {
            case .success(let users):
                self.model.usersByID = users
            case .failure:
                self.model.usersByID = [:]
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView () {
        let users = model.usersByID.values.sorted().reduce(into: [ViewModel.Item]()) {
            $0.append(ViewModel.Item(user: $1, isFollowed: model.followedUsers.contains($1)))
        }
        
        let itemsBySection = [0: users]
        
        dataSource.applySnapshotUsing(sectionIDs: [0], itemsBySection: itemsBySection)
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) {
            let cell = $0.dequeueReusableCell(withReuseIdentifier: "User", for: $1) as! PrimarySecondaryTextCollectionViewCell
            cell.primaryTextLabel.text = $2.user.name
            return cell
        }
        
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.45))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            group.interItemSpacing = .fixed(20)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)

            return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: UICollectionViewDataSource
extension UserCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
}

extension UserCollectionViewController {
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        typealias Section = Int
    
        struct Item: Hashable {
            let user: User
            let isFollowed: Bool
        }
    }
    
    struct Model {
        var usersByID = [String: User]()
        var followedUsers: [User] {
            return Array(usersByID.filter { Settings.shared.followedUserIDs.contains($0.key) }.values)
        }
    }
}
