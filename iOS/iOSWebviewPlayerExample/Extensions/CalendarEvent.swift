//
//  BambuserViewController+EventKit.swift
//  iOSWebviewPlayerExample
//
//  Created by Göran Lilja on 2022-04-22.
//

import EventKit

struct CalendarEvent: Equatable {
    /**
     Create an audio session configuration

     - Parameters:
       - title: The calendar event title
       - startDate: The calendar event start date
       - endDate: The calendar event end date
       - url: The url to add to the event
     */
    public init(
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        url: URL) {
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.url = url
    }

    /**
     The calendar event title.
     */
    public let title: String

    /**
     The calendar event description.
     */
    public let description: String

    /**
     The calendar event start date.
     */
    public let startDate: Date

    /**
     The calendar event end date.
     */
    public let endDate: Date

    /**
     The url to add to the event.
     */
    public let url: URL


    /**
     This typealias represents an action that will be called
     when an add to calendar operation complets.
     */
    public typealias AddToCalendarCompletion = (AddToCalendarResult) -> Void

    /**
     This typealias represents an add to calendar result.
     */
    public typealias AddToCalendarResult = Result<Void, AddToCalendarError>

    /**
     This typealias represents an action that will be called
     to pick a calendar from the provided event store.
     */
    public typealias CalendarPicker = (EKEventStore) -> EKCalendar?

    /**
     This typealias represents an action that will be called
     to pick an event store from which to pick calendars.
     */
    public typealias StorePicker = () -> EKEventStore

    /**
     This enum represents errors that can occur while adding
     a calendar event to a calendar.
     */
    public enum AddToCalendarError: Error {

        /// The user has not granted access to the calendar.
        case calendarAccessNotGranted

        /// A default calendar could not be found.
        case defaultCalendarNotFound

        /// A general error occurred.
        case error(Error)
    }

    /**
     Save the event to a certain calendar, using `EventKit`.

     To use the feature, any app that executes this function
     must have an `NSCalendarsUsageDescription` key added to
     its `Info.plist`. Otherwise, the app will crash.
     */
    func saveToCalendar(
        _ calendar: @escaping CalendarPicker = { $0.defaultCalendarForNewEvents },
        in store: @escaping StorePicker = { EKEventStore() },
        completion: @escaping AddToCalendarCompletion) {
        let store = store()
        store.requestAccess(to: .event) { (granted, error) in
            DispatchQueue.main.async {
                do {
                    if let error = error { throw(err(.error(error))) }
                    guard granted else { throw(err(.calendarAccessNotGranted)) }
                    guard let cal = calendar(store) else { throw(err(.defaultCalendarNotFound)) }
                    let event = event(for: cal, in: store)
                    try store.save(event, span: .thisEvent, commit: true)
                    completion(.success(()))
                } catch {
                    return completion(.failure(.error(error)))
                }
            }
        }
    }
}

private extension CalendarEvent {

    func err(_ error: AddToCalendarError) -> AddToCalendarError { error }

    func event(for calendar: EKCalendar, in store: EKEventStore) -> EKEvent {
        let event = EKEvent(eventStore: store)
        event.title = title
        event.notes = description
        event.url = url
        event.startDate = startDate
        event.isAllDay = false
        event.endDate = endDate
        event.calendar = calendar
        return event
    }
}
