//
//  ViewController.swift
//  DiffableTableMe
//
//  Created by Tomato on 2021/11/02.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDragDelegate, UITableViewDropDelegate, TableDataSourceDelegate {
	// MARK: - Variables
	var dataSource: TableDataSource?
	var videoGames: [VideoGame] = VideoGame.data
	
	
	// MARK: - IBOutlet
	@IBOutlet weak var tableView: UITableView!
	
	
	// MARK: - IBAction
	@IBAction func updateTapped(_ sender: UIButton) {
		/*
		let newGame = VideoGame(name: "Civilization IV", place: 4)
		videoGames.append(newGame)
		
		videoGames.sort {
			$0.place < $1.place
		}
		
		guard let dataSource = self.dataSource else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, VideoGame>()
		snapshot.appendSections([0])
		snapshot.appendItems(videoGames, toSection: 0)
		dataSource.apply(snapshot, animatingDifferences: true)
		*/
		
		for videoGame in videoGames {
			print("Name: \(videoGame.name) Place: \(videoGame.place)")
		}
	}
	
	@IBAction func switchChange(_ sender: UISwitch) {
		tableView.setEditing(sender.isOn, animated: true)
		dataSource?.canMoveEdit = sender.isOn
	}
	
	
	// MARK: - Life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dragDelegate = self
		tableView.dropDelegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		dataSource = TableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			let videoGame = self.videoGames[indexPath.row]
			cell.textLabel?.text = videoGame.name
			return cell
		})
		tableView.dataSource = dataSource
		dataSource?.tableDataSourceDelegate = self
		
		guard let dataSource = self.dataSource else {
			return
		}
		var snapshot = dataSource.snapshot()
		snapshot.appendSections([0])
		snapshot.appendItems(videoGames, toSection: 0)
		dataSource.apply(snapshot)
		
	}
	
	deinit {
		print("deinit is called by HomeViewController")
	}
	
	
	// MARK: - TableView
	func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
		return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
	}
	
	func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
		// If you don't use diffable data source, you'll need to reconcile your local data store here.
		// In our case, we do so in the diffable datasource subclass.
	}
	
	func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let item = dataSource?.itemIdentifier(for: indexPath) else {
			return []
		}
		let itemProvider = NSItemProvider(object: item.id.uuidString as NSString)
		let dragItem = UIDragItem(itemProvider: itemProvider)
		dragItem.localObject = item
		return [dragItem]
	}
	
	
	
	// MARK: - Delegate
	func dataDidChange(sourceIndex: Int, destIndex: Int) {
		let sourceItem = videoGames[sourceIndex]
		videoGames.remove(at: sourceIndex)
		videoGames.insert(sourceItem, at: destIndex)
		
		for i in 0..<videoGames.count {
			let oldGame = videoGames[i]
			let newGame = VideoGame(name: oldGame.name, place: i)
			videoGames.remove(at: i)
			videoGames.insert(newGame, at: i)
		}
	}
	
	func dataWillDelete(indexPath: IndexPath) {
		videoGames.remove(at: indexPath.row)
		
		guard let dataSource = self.dataSource else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, VideoGame>()
		snapshot.appendSections([0])
		snapshot.appendItems(videoGames, toSection: 0)
		dataSource.apply(snapshot, animatingDifferences: true)
	}
}

protocol TableDataSourceDelegate: Any {
	func dataDidChange(sourceIndex: Int, destIndex: Int)
	
	func dataWillDelete(indexPath: IndexPath)
}

class TableDataSource: UITableViewDiffableDataSource<Int, VideoGame> {
	var tableDataSourceDelegate : TableDataSourceDelegate?
	var canMoveEdit = false
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return canMoveEdit
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		guard let fromGame = itemIdentifier(for: sourceIndexPath), sourceIndexPath != destinationIndexPath else { return }
		var snap = snapshot()
		snap.deleteItems([fromGame])
		
		if let toGame = itemIdentifier(for: destinationIndexPath) {
			let isAfter = destinationIndexPath.row > sourceIndexPath.row
			if isAfter {
				snap.insertItems([fromGame], afterItem: toGame)
			} else {
				snap.insertItems([fromGame], beforeItem: toGame)
			}
		} else {
			snap.appendItems([fromGame], toSection: sourceIndexPath.section)
		}
		apply(snap, animatingDifferences: false)
		
		/* delegate call */
		tableDataSourceDelegate?.dataDidChange(sourceIndex: sourceIndexPath.row, destIndex: destinationIndexPath.row)
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			tableDataSourceDelegate?.dataWillDelete(indexPath: indexPath)
		}
	}
}


struct VideoGame: Hashable {
	let id = UUID()
	let name: String
	let place: Int
}

extension VideoGame {
	static var data = [VideoGame(name: "Mass Effect", place: 0),
					   VideoGame(name: "Pokemon", place: 1),
					   VideoGame(name: "Super Mario Brothers", place: 2),
					   VideoGame(name: "Halo", place: 4),
					   VideoGame(name: "Dooms 2", place: 5),
					   VideoGame(name: "Castlevania", place: 6)
	]
}

