//
//  CoreDataStack.swift
//  family-dao
//
//  Created by KittenYang on 10/2/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Foundation
import CoreData
import Combine

class XXXX: NSObject{}
public class CoreDataStack: CoreDataProtocol {

	public static let shared = CoreDataStack()
	
	private var subscribers = Set<AnyCancellable>()

	public static var appGroupId: String = "group.com.kittenyang.family-dao"

	public lazy var managedObjectModel: NSManagedObjectModel = {
		let bundle = Bundle.init(for: XXXX().classForCoder)
		let modelURL = bundle.url(forResource: "MultiSigKit", withExtension: "momd")
		let managedObjectModel = NSManagedObjectModel.init(contentsOf: modelURL!)
		return managedObjectModel!
	}()
		
	// Loads core data store and migrates from previous versions if needed.
	public lazy var persistentContainer: NSPersistentContainer = {
		// By default, container configured with database located in app sandbox.
		let container = NSPersistentContainer(name: "MultiSigKit", managedObjectModel: self.managedObjectModel)

		// Get the default location
		let defaultStoreUrl = container.persistentStoreDescriptions.first?.url
		let defaultStoreExists = defaultStoreUrl != nil && FileManager.default.fileExists(atPath: defaultStoreUrl!.path)

		// Get app group container location
		guard let appGroupContainerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupId) else {
			fatalError("Expected to have App Group set up with id: \(Self.appGroupId)")
		}

		// Check if already migrated default store to the shared app group location
		let sharedStoreUrl = appGroupContainerUrl.appendingPathComponent("MultiSigKit").appendingPathExtension("sqlite")
		var sharedStoreExists = FileManager.default.fileExists(atPath: sharedStoreUrl.path)

		let didNotMigrate = defaultStoreExists && !sharedStoreExists

		if !didNotMigrate {
			container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: sharedStoreUrl)]
		}

		container.loadPersistentStores { [unowned container] storeDescription, error in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

				/*
				 Typical reasons for an error here include:
				 * The parent directory does not exist, cannot be created, or disallows writing.
				 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
				 * The device is out of space.
				 * The store could not be migrated to the current model version.
				 Check the error message to determine what the actual problem was.
				 */
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}


			// migrate store if needed
			if didNotMigrate,
			   let defaultStore = container.persistentStoreCoordinator.persistentStore(for: defaultStoreUrl!) {
				do {
					try container.persistentStoreCoordinator.migratePersistentStore(
						defaultStore,
						to: sharedStoreUrl,
						options: nil,
						withType: defaultStore.type)

					sharedStoreExists = true
				} catch {
					print("Failed to migrate persistent store to new location: \(error)")
					sharedStoreExists = false
				}
			}

			if defaultStoreExists && sharedStoreExists {
				try? FileManager.default.removeItem(at: defaultStoreUrl!)
			}

			// merge changes from background contexts into the view context
			NotificationCenter.default
				.publisher(for: Notification.Name.NSManagedObjectContextDidSave)
				.receive(on: RunLoop.main)
				.sink { [weak container] notification in
					let savedMOC = notification.object as! NSManagedObjectContext
					guard let container = container,
						  savedMOC != container.viewContext,
						  savedMOC.persistentStoreCoordinator == container.persistentStoreCoordinator else { return }
					container.viewContext.mergeChanges(fromContextDidSave: notification)
				}
				.store(in: &self.subscribers)

		}
		return container
	}()
	
	func saveContext () {
		if viewContext.hasChanges {
			do {
				try viewContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}

	func rollback() {
		if viewContext.hasChanges {
			viewContext.rollback()
		}
	}
}

extension CoreDataStack.Version {
	static var actual: UInt { 1 }
}

extension CoreDataStack {
	struct Version {
		private let number: UInt
		
		init(_ number: UInt) {
			self.number = number
		}
		
		var modelName: String {
			return "MultiSigKit"
		}
		
		func dbFileURL(_ directory: FileManager.SearchPathDirectory,
					   _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
			return FileManager.default
				.urls(for: directory, in: domainMask).first?
				.appendingPathComponent(subpathToDB)
		}
		
		private var subpathToDB: String {
			return "MultiSigKit.sqlite"
		}
	}
}


extension NSManagedObjectContext {
	
	func configureAsReadOnlyContext() {
		automaticallyMergesChangesFromParent = true
		mergePolicy = NSRollbackMergePolicy
		undoManager = nil
		shouldDeleteInaccessibleFaults = true
	}
	
	func configureAsUpdateContext() {
		mergePolicy = NSOverwriteMergePolicy
		undoManager = nil
	}
}
