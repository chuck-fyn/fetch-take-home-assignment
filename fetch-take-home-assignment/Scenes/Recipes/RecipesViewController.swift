//
//  RecipesViewController.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Combine
import UIKit

final class RecipesViewController: UIViewController {
    
    private let viewModel: RecipesViewModel

    lazy var dataSource = configureDataSource()
    
    var collectionView: UICollectionView!
    
    private let refreshControl = UIRefreshControl()
    
    var indicatorView: UIActivityIndicatorView = {
        var indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    var noRecipesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No recipes available at this time.\n\nPlease swipe down to refresh, or try again at a later time."
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    let sortByCuisineAction: UIAction
    let sortByNameAction: UIAction

    lazy var sortMenu: UIMenu = {
        return UIMenu(title: "Sort", options: .displayInline, children: [sortByCuisineAction, sortByNameAction])
    }()
    
    init(viewModel: RecipesViewModel) {
        self.viewModel = viewModel
        
        sortByCuisineAction = UIAction(title: "By Cuisine") { _ in
            viewModel.sortByCuisine()
        }
        
        sortByNameAction = UIAction(title: "By Dish Name") { _ in
            viewModel.sortByName()
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.reuseIdentifier)
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        
        navigationItem.title = "Recipes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.line3Horizontal, menu: sortMenu)
                
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(indicatorView)
        view.addSubview(noRecipesLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            noRecipesLabel.widthAnchor.constraint(equalToConstant: 200),
            noRecipesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noRecipesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        configureBindings()
        loadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    
    private func loadData() {
        viewModel.getRecipes()
    }
    
    private func configureBindings() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] viewState in
                switch viewState {
                case .loaded:
                    self?.indicatorView.isHidden = true
                    self?.indicatorView.stopAnimating()
                    self?.collectionView.isHidden = false
                    if self!.viewModel.recipes.isEmpty {
                        self?.noRecipesLabel.isHidden = false
                        self?.navigationItem.rightBarButtonItem?.isEnabled = false
                    } else {
                        self?.noRecipesLabel.isHidden = true
                        self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                case .loading:
                    self?.indicatorView.isHidden = false
                    self?.indicatorView.startAnimating()
                    self?.collectionView.isHidden = true
                    self?.noRecipesLabel.isHidden = true
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                case .failed:
                    self?.indicatorView.isHidden = true
                    self?.indicatorView.stopAnimating()
                    self?.collectionView.isHidden = false
                    self?.noRecipesLabel.isHidden = false
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                }
            }
            .store(in: &viewModel.disposeBag)
        
        viewModel.$recipes
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] viewModels in
                var snapshot = NSDiffableDataSourceSnapshot<Section, RecipeCellViewModel>()
                snapshot.appendSections(Section.allCases)
                snapshot.appendItems(viewModels, toSection: .main)
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            })
            .store(in: &viewModel.disposeBag)
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        self.loadData()
        refreshControl.endRefreshing()
    }
}

// MARK: - CollectioNView DataSource
extension RecipesViewController {
    enum Section: Int, CaseIterable {
        case main
    }
    
    func configureDataSource() -> UICollectionViewDiffableDataSource<Section, RecipeCellViewModel> {
         UICollectionViewDiffableDataSource(
             collectionView: collectionView,
             cellProvider: { [weak self] collectionView, indexPath, product in
                 guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCollectionViewCell.reuseIdentifier, for: indexPath) as? RecipeCollectionViewCell,
                       let viewModel = self?.viewModel.recipes[indexPath.row] else { return UICollectionViewCell() }
                 cell.viewModel = viewModel
                 cell.configure()
                 return cell
             }
         )
     }
}

// MARK: - CollectioNView Layout
extension RecipesViewController {
    func makeGridLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.31),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(UIScreen.main.bounds.width),
            heightDimension: .absolute(220)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0.0,  leading: 15.0,  bottom: 0.0,  trailing: 15.0)
        
        return section
    }
    
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            return self?.makeGridLayoutSection()
        }
    }
}

// MARK: - CollectioNView Delegate
extension RecipesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        Task.detached { [weak self] in
            await self?.viewModel.recipes[indexPath.row].cancelLoading()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.recipes[indexPath.row].loadImageData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeName = viewModel.recipes[indexPath.row].recipe.name.capitalized
        let actionSheetController = UIAlertController(title: recipeName, message: nil, preferredStyle: .actionSheet)

        if let sourceUrl = viewModel.recipes[indexPath.row].recipe.source_url {
            let action1 = UIAlertAction(title: "Printed Recipe", style: .default) { [self] _ in
                showWebView(sourceUrl)
            }
            actionSheetController.addAction(action1)
        }
        
        if let videoUrl = viewModel.recipes[indexPath.row].recipe.youtube_url {
            let action2 = UIAlertAction(title: "Video Recipe", style: .default) { [self] _ in
                showWebView(videoUrl)
            }
            actionSheetController.addAction(action2)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Handle Cancel button tap
        }
        actionSheetController.addAction(cancelAction)

        present(actionSheetController, animated: true, completion: nil)
    }
}
