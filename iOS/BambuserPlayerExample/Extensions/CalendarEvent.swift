//
//  BambuserViewController+EventKit.swift
//  iOSWebviewPlayerExample
//
//  Created by Göran Lilja on 2022-04-22.
//

import EventKit

struct CalendarEvent: Decodable, Equatable {

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

    enum CodingKeys: String, CodingKey {
        case title, description, start, duration, url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions.insert(.withFractionalSeconds)

        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)

        let startDateString = try container.decode(String.self, forKey: .start)
        guard let formattedStartDate = dateFormatter.date(from: startDateString) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.start], debugDescription: "Invalid startDate date formatting"))
        }
        startDate = formattedStartDate

        let duration = try container.decode(Double.self, forKey: .duration)
        endDate = startDate.addingTimeInterval(duration / 1000)

        let urlString = try container.decode(String.self, forKey: .url)
        guard let urlFromString = URL(string: urlString) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.url], debugDescription: "Invalid url"))
        }
        url = urlFromString
    }


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
