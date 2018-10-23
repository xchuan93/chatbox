//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//


enum LocalSearchEvent {

    case receivedResult(startedAt: Date?)
    case selected

    var name: String {
        switch self {
        case .receivedResult: return "collection.entered_search" // Whenever the app returns a search result
        case .selected: return "collection.selected_search_result " // User selects a search result
        }
    }

    var attributes: [String: String]? {
        switch self {
        case .receivedResult(startedAt: let date):
            guard let date = date else { return nil }
            guard let clusterized = TimeIntervalClusterizer.default().clusterizeTimeInterval(-date.timeIntervalSinceNow) else { return nil }
            return ["search_duration": clusterized]
        default: return nil
        }
    }

}


extension Analytics {

    func tag(searchEvent: LocalSearchEvent) {
        tagEvent(searchEvent.name, attributes: searchEvent.attributes ?? [:])
    }

}
