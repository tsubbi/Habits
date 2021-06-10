//
//  UICollectionViewDiffableDataSource+ViewModel.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-10.
//

import UIKit
import Foundation

extension UICollectionViewDiffableDataSource {
    func applySnapshotUsing(sectionIDs: [SectionIdentifierType],
                            itemsBySection: [SectionIdentifierType: [ItemIdentifierType]],
                            sectionsRetainedIfEmpty: Set<SectionIdentifierType> = Set<SectionIdentifierType>()) {
        applySnapshotUsing(sectionIDs: sectionIDs,
                           itemsBySection: itemsBySection,
                           animatingDifferences: true,
                           sectionsRetainedIfEmpty: sectionsRetainedIfEmpty)
    }
    
    func applySnapshotUsing(sectionIDs: [SectionIdentifierType],
                            itemsBySection: [SectionIdentifierType: [ItemIdentifierType]],
                            animatingDifferences: Bool,
                            sectionsRetainedIfEmpty: Set<SectionIdentifierType> = Set<SectionIdentifierType>()) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        for id in sectionIDs {
            guard let items = itemsBySection[id],
                  items.count > 0 || sectionsRetainedIfEmpty.contains(id) else {
                continue
            }
            
            snapshot.appendSections([id])
            snapshot.appendItems(items, toSection: id)
        }
        
        self.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
