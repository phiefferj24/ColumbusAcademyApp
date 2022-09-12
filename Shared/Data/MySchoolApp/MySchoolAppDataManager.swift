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
                fatalError("Error initializing CoreData: \(error), \(error.userInfo)")
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
        let results = try backgroundContext.fetch(NSFetchRequest<MySchoolAppScheduleListEntity>(entityName: "MySchoolAppScheduleListEntity"))
        for result in results.filter({ $0.date == date }) {
            backgroundContext.delete(result)
        }
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
            scheduleListElementEntity.relationship = scheduleListEntity
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
                }
            }
            return scheduleList
        }
        return nil
    }
    
    func setCalendars(_ calendar: MySchoolAppCalendarList, from start: Date, to end: Date) throws {
        let results = try backgroundContext.fetch(NSFetchRequest<MySchoolAppCalendarListEntity>(entityName: "MySchoolAppCalendarListEntity"))
        for result in results.filter({ $0.startDate == start && $0.endDate == end }) {
            backgroundContext.delete(result)
        }
        let calendarListEntity = MySchoolAppCalendarListEntity(context: backgroundContext)
        calendarListEntity.startDate = start
        calendarListEntity.endDate = end
        for item in calendar {
            let calendarListElementEntity = MySchoolAppCalendarListElementEntity(context: backgroundContext)
            calendarListElementEntity.associationId = Int32(item.associationId)
            calendarListElementEntity.backgroundColor = item.backgroundColor
            calendarListElementEntity.calendar = item.calendar
            calendarListElementEntity.calendarId = item.calendarId
            calendarListElementEntity.filterName = item.filterName
            calendarListElementEntity.filterLeadPk = Int32(item.filterLeadPk ?? -1)
            for filter in item.filters ?? [] {
                let calendarListFilterElementEntity = MySchoolAppCalendarListElementEntity(context: backgroundContext)
                calendarListFilterElementEntity.associationId = Int32(filter.associationId)
                calendarListFilterElementEntity.backgroundColor = filter.backgroundColor
                calendarListFilterElementEntity.calendar = filter.calendar
                calendarListFilterElementEntity.calendarId = filter.calendarId
                calendarListFilterElementEntity.filterName = filter.filterName
                calendarListFilterElementEntity.filterLeadPk = Int32(filter.filterLeadPk ?? -1)
                calendarListElementEntity.addToFilters(calendarListFilterElementEntity)
            }
            calendarListElementEntity.relationship = calendarListEntity
            calendarListEntity.addToRelationship(calendarListElementEntity)
        }
        try backgroundContext.save()
    }
    
    func getCalendars(from start: Date, to end: Date) throws -> MySchoolAppCalendarList? {
        let results = try backgroundContext.fetch(NSFetchRequest<MySchoolAppCalendarListEntity>(entityName: "MySchoolAppCalendarListEntity"))
        if let calendarListEntity = results.first(where: { $0.startDate == start && $0.endDate == end }),
           let relationship = calendarListEntity.relationship {
            var calendarList = MySchoolAppCalendarList()
            for calendarListElementEntity in relationship.array {
                if let calendarListElementEntity = calendarListElementEntity as? MySchoolAppCalendarListElementEntity {
                    var filters: MySchoolAppCalendarList? = nil
                    if let filtersSet = calendarListElementEntity.filters {
                        filters = MySchoolAppCalendarList()
                        for filterEntity in filtersSet {
                            if let filterEntity = filterEntity as? MySchoolAppCalendarListElementEntity {
                                filters!.append(
                                    MySchoolAppCalendarListElement(
                                        associationId: Int(filterEntity.associationId),
                                        backgroundColor: filterEntity.backgroundColor,
                                        calendar: filterEntity.calendar ?? "",
                                        calendarId: filterEntity.calendarId ?? "",
                                        filterName: filterEntity.filterName,
                                        filterLeadPk: Int(filterEntity.filterLeadPk),
                                        filters: nil
                                    )
                                )
                            }
                        }
                    }
                    calendarList.append(
                        MySchoolAppCalendarListElement(
                            associationId: Int(calendarListElementEntity.associationId),
                            backgroundColor: calendarListElementEntity.backgroundColor,
                            calendar: calendarListElementEntity.calendar ?? "",
                            calendarId: calendarListElementEntity.calendarId ?? "",
                            filterName: calendarListElementEntity.filterName,
                            filterLeadPk: Int(calendarListElementEntity.filterLeadPk),
                            filters: filters
                        )
                    )
                }
            }
            return calendarList
        }
        return nil
    }
    
    func setEvents(_ events: MySchoolAppEventList, from start: Date, to end: Date) throws {
        let results = try backgroundContext.fetch(NSFetchRequest<MySchoolAppEventListEntity>(entityName: "MySchoolAppEventListEntity"))
        for result in results.filter({ $0.startDate == start && $0.endDate == end }) {
            backgroundContext.delete(result)
        }
        let eventListEntity = MySchoolAppEventListEntity(context: backgroundContext)
        eventListEntity.startDate = start
        eventListEntity.endDate = end
        for item in events {
            let eventListElementEntity = MySchoolAppEventListElementEntity(context: backgroundContext)
            eventListElementEntity.startDate = item.startDate
            eventListElementEntity.endDate = item.endDate
            eventListElementEntity.allDay = item.allDay
            eventListElementEntity.eventId = Int32(item.eventId)
            eventListElementEntity.title = item.title
            eventListElementEntity.briefDescription = item.briefDescription
            eventListElementEntity.groupId = Int32(item.groupId)
            eventListElementEntity.relationship = eventListEntity
            eventListEntity.addToRelationship(eventListElementEntity)
        }
        try backgroundContext.save()
    }
    
    func getEvents(from start: Date, to end: Date) throws -> MySchoolAppEventList? {
        let results = try backgroundContext.fetch(NSFetchRequest<MySchoolAppEventListEntity>(entityName: "MySchoolAppEventListEntity"))
        if let eventListEntity = results.first(where: { $0.startDate == start && $0.endDate == end }),
           let relationship = eventListEntity.relationship {
            var eventList = MySchoolAppEventList()
            for eventListElementEntity in relationship.array {
                if let eventListElementEntity = eventListElementEntity as? MySchoolAppEventListElementEntity {
                    eventList.append(
                        MySchoolAppEventListElement(
                            briefDescription: eventListElementEntity.briefDescription ?? "",
                            endDate: eventListElementEntity.endDate ?? "",
                            eventId: Int(eventListElementEntity.eventId),
                            groupId: Int(eventListElementEntity.groupId),
                            startDate: eventListElementEntity.startDate ?? "",
                            title: eventListElementEntity.title ?? "",
                            allDay: eventListElementEntity.allDay
                        )
                    )
                }
            }
            return eventList
        }
        return nil
    }
    
    func save() throws {
        if backgroundContext.hasChanges {
            try backgroundContext.save()
        }
    }
}
