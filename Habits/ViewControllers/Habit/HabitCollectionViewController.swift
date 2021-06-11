//
//  HabitCollectionViewController.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-10.
//

import UIKit

private let reuseIdentifier = "Cell"

class HabitCollectionViewController: UICollectionViewController {
    
    /// constant
    private let sectionHeaderKind = "SectionHeader"
    private let sectionHeaderIdentifier = "HeaderView"
    
    var dataSource: DataSourceType!
    var model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        collectionView.register(NamedSectionHeaderView.self, forSupplementaryViewOfKind: sectionHeaderKind, withReuseIdentifier: sectionHeaderIdentifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    func update() {
        HabitRequest().send {
            switch $0 {
            case .success(let habits):
                self.model.habitByName = habits
            case .failure:
                self.model.habitByName = [:]
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView() {
        var itemsBySection = model.habitByName.values.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) {
            let section: ViewModel.Section
            let item: ViewModel.Item
            if model.favoriteHabits.contains($1) {
                section = .favorates
                item = ViewModel.Item(habit: $1, isFavorite: true)
            } else {
                section = .category($1.category)
                item = ViewModel.Item(habit: $1, isFavorite: false)
            }

            $0[section, default: []].append(item)
        }
        itemsBySection = itemsBySection.mapValues { $0.sorted() }
        
        let sectionIDs = itemsBySection.keys.sorted()
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) {
            let cell = $0.dequeueReusableCell(withReuseIdentifier: "Habit", for: $1) as! PrimarySecondaryTextCollectionViewCell
            
            cell.primaryTextLabel.text = $2.habit.name
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = {
            let header = $0.dequeueReusableSupplementaryView(ofKind: self.sectionHeaderKind,
                                                             withReuseIdentifier: self.sectionHeaderIdentifier, for: $2) as! NamedSectionHeaderView
            
            let section = dataSource.snapshot().sectionIdentifiers[$2.section]
            switch section {
            case .favorates:
                header.nameLabel.text = "Favorites"
            case .category(let category):
                header.nameLabel.text = category.name
            }
            
            return header
        }
        
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: sectionHeaderKind, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    @IBSegueAction func showHabitDetail(_ coder: NSCoder, sender: UICollectionViewCell?) -> HabitDetailViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        return HabitDetailViewController(coder: coder, habit: item.habit)
    }
}

// MARK: Collection View Data Source
extension HabitCollectionViewController {
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

// MARK: Collection View Data Delegate
extension HabitCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView,
                                 contextMenuConfigurationForItemAt indexPath: IndexPath,
                                 point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil,
                                                previewProvider: nil) { _ in
            let item = self.dataSource.itemIdentifier(for: indexPath)!
            let favoriteToggle = UIAction(title: item.isFavorite ? "Unfavorite" : "Faorite") { _ in
                Settings.shared.googleFavorite(item.habit)
                self.updateCollectionView()
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [favoriteToggle])
        }
        
        return config
    }
}

extension HabitCollectionViewController {
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum  Section: Hashable, Equatable, Comparable {
            case favorates
            case category(_ category: Category)
            
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.category(let l), .category(let r)):
                    return l.name < r.name
                case (.favorates, _):
                    return true
                case (_, .favorates):
                    return false
                }
            }
        }
        
        struct Item: Hashable, Equatable, Comparable {
            let habit: Habit
            let isFavorite: Bool
            
            static func < (lhs: Item, rhs: Item) -> Bool {
                return lhs.habit < rhs.habit
            }
        }
    }
    
    struct Model {
        var habitByName = [String: Habit]()
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
    }
}
