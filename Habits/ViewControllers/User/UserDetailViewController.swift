//
//  UserDetailViewController.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-10.
//

import UIKit

class UserDetailViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    var dataSource: DataSourceType!
    var model = Model()
    var updateTimer: Timer?
    private let headerIdentifier = "HeaderView"
    private let headerKind = "SectionHeader"
    
    init?(coder: NSCoder, user: User) {
        self.user = user
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = user.name
        bioLabel.text = user.bio
        
        // register cell
        collectionView.register(NamedSectionHeaderView.self, forSupplementaryViewOfKind: headerKind, withReuseIdentifier: headerIdentifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()

        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        update()

        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.update()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func update() {
        UserStatisticsRequest(userIDs: [user.id]).send { result in
            switch result {
            case .success(let userStats):
                self.model.userStats = userStats[0]
            case .failure:
                self.model.userStats = nil
            }

            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }

        HabitLeadStatisticsRequest(userID: user.id).send { result in
            switch result {
            case .success(let userStats):
                self.model.leadingStats = userStats
            case .failure:
                self.model.leadingStats = nil
            }

            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView() {
        guard let userStatistics = model.userStats,
            let leadingStatistics = model.leadingStats else { return }

        var items = userStatistics.habitCounts.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) {
            let section: ViewModel.Section
            
            section = leadingStatistics.habitCounts.contains($1) ? .leading : .category($1.habit.category)
            $0[section, default: []].append($1)
        }

        items = items.mapValues { $0.sorted() }
        let IDs = items.keys.sorted()

        dataSource.applySnapshotUsing(sectionIDs: IDs, itemsBySection: items)
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, habitStat) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCount", for: indexPath) as! PrimarySecondaryTextCollectionViewCell

            cell.primaryTextLabel.text = habitStat.habit.name
            cell.secondaryTextLabel.text = "\(habitStat.count)"

            return cell
        }

        dataSource.supplementaryViewProvider = {
            let header = $0.dequeueReusableSupplementaryView(ofKind: self.headerKind, withReuseIdentifier: self.headerIdentifier, for: $2) as! NamedSectionHeaderView

            let section = dataSource.snapshot().sectionIdentifiers[$2.section]

            switch section {
            case .leading:
                header.nameLabel.text = "Leading"
            case .category(let category):
                header.nameLabel.text = category.name
            }
            return header
        }

        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
        sectionHeader.pinToVisibleBounds = true

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        section.boundarySupplementaryItems = [sectionHeader]

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension UserDetailViewController {
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>

    enum ViewModel {
        typealias Item = HabitCount
        
        enum Section: Hashable, Comparable {
            case leading
            case category(_ category: Category)

            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.leading, .category), (.leading, .leading):
                    return true
                case (.category, .leading):
                    return false
                case (category(let category1), category(let category2)):
                    return category1.name > category2.name
                }
            }
        }
    }

    struct Model {
        var userStats: UserStatistics?
        var leadingStats: UserStatistics?
    }
}
