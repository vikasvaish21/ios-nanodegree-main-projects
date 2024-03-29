//
//  HeroesViewController+CollectionView.swift
//  MarvelComics
//
//  Created by vikas on 14/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import Foundation
import UIKit

extension HeroesViewController: HeroCellDelegate{
    func didTapFavourite(_ heroViewCell: HeroCollectionViewCell, hero: Hero?, myHero: MyHero?) {
        guard let hero = hero else {
            return
        }
        
        heroViewCell.favButton.isEnabled = false
        
        if let myHero = myHero {
            /* Unfavorite hero */
            delete(myHero: myHero) { error in
                DispatchQueue.main.async {
                    if error == nil {
                        heroViewCell.myHero = nil
                    }
                    heroViewCell.favButton.isEnabled = true
                }
            }
        } else {
            /* Favorite hero */
            save(hero: hero, heroImage: heroViewCell.thumbImageView) { (myHero, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        heroViewCell.myHero = myHero
                    }
                    heroViewCell.favButton.isEnabled = true
                }
            }
        }
    }
}

extension HeroesViewController: UICollectionViewDataSource {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.backgroundView = heroes.count == 0 ? noResultsLabel : nil
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroCollectionViewCell.identifier, for: indexPath) as! HeroCollectionViewCell
        
        let hero = heroes[indexPath.row]
        guard let heroID = hero.id else {
            return cell
        }
        
        getMyHero(with: heroID) { (myHero) in
            cell.prepareCell(with: hero, myHero: myHero)
            cell.delegate = self
        }
        
    return cell
}
    
    // MARK: - Infinite Scroll
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == heroes.count - MarvelApiContent.Constants.InfiniteScrollLimiar &&
            !loadingAction &&
            heroes.count < total
        {
            currentPage += 1
            loadHeroes()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: FooterActivityIndicatorView.identifier, for: indexPath) as! FooterActivityIndicatorView
        footerView.activityIndicator.startAnimating()
        return footerView
    }
    
    // MARK: - Select hero
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let hero = heroes[indexPath.row]
        let heroCell = collectionView.cellForItem(at: indexPath) as! HeroCollectionViewCell
        navToHeroDetails(with: hero, heroImage: heroCell.thumbImageView.image)
    }
}

extension HeroesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 8
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize / 2, height: collectionViewSize / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return total > heroes.count ? CGSize(width: collectionView.frame.size.width, height: 50) : CGSize(width: 0, height: 0)
    }
}
