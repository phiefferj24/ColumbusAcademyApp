//
//  MySchoolAppDataManager.swift
//  CA (iOS)
//
//  Created by Jim Phieffer on 8/30/22.
//

import Foundation
import CoreData

actor MySchoolAppDataManager {
    static let shared = MySchoolAppDataManager()
    
    var persistentContainer: NSPersistentContainer
    
    var backgroundContext: NSManagedObjectContext
    
    init() {
        persistentContainer = NSPersistentContainer(name: "MySchoolAppDatabase")
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error as? NSError {
                fatalError("Error initializing CoreData: \(error.localizedDescription), \(error.userInfo)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try? persistentContainer.viewContext.setQueryGenerationFrom(.current)
        
        backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try? backgroundContext.setQueryGenerationFrom(.current)
    }
    
    func setSchedule(_ schedule: MySchoolAppScheduleList, for date: Date) throws {
        let scheduleListEntity = MySchoolAppScheduleListEntity(context: backgroundContext)
        scheduleListEntity.date = date
        for item in schedule {
            let scheduleListElementEntity = MySchoolAppScheduleListElementEntity(context: backgroundContext)
            scheduleListElementEntity.courseTitle = item.courseTitle
            scheduleListElementEntity.startTime = item.startTime
            scheduleListElementEntity.endTime = item.endTime
            scheduleListElementEntity.block = item.block
            scheduleListElementEntity.roomNumber = item.roomNumber
            scheduleListElementEntity.buildingName = item.buildingName
            scheduleListElementEntity.myDayStartTime = item.myDayStartTime
            scheduleListElementEntity.myDayEndTime = item.myDayEndTime
            scheduleListEntity.addToRelationship(scheduleListElementEntity)
        }
        try backgroundContext.save()
    }
    
    func getSchedule(for date: Date) throws -> MySchoolAppScheduleList? {
        let results = try backgroundContext.fetch(NSFetchRequest<MySchoolAppScheduleListEntity>(entityName: "MySchoolAppScheduleListEntity"))
        if let scheduleListEntity = results.first(where: { $0.date == date }),
           let relationship = scheduleListEntity.relationship {
            var scheduleList = MySchoolAppScheduleList()
            for scheduleListElementEntity in relationship.array {
                if let scheduleListElementEntity = scheduleListElementEntity as? MySchoolAppScheduleListElementEntity {
                    scheduleList.append(
                        MySchoolAppScheduleListElement(
                            courseTitle: scheduleListElementEntity.courseTitle ?? "",
                            startTime: scheduleListElementEntity.startTime ?? "",
                            endTime: scheduleListElementEntity.endTime ?? "",
                            block: scheduleListElementEntity.block ?? "",
                            roomNumber: scheduleListElementEntity.roomNumber ?? "",
                            buildingName: scheduleListElementEntity.buildingName ?? "",
                            myDayStartTime: scheduleListElementEntity.myDayStartTime ?? "",
                            myDayEndTime: scheduleListElementEntity.myDayEndTime ?? ""
                        )
                    )
                }else { print("b")}
            }
        } else { print("a")}
        return nil
    }
    
    func save() throws {
        if backgroundContext.hasChanges {
            try backgroundContext.save()
        }
    }
}
