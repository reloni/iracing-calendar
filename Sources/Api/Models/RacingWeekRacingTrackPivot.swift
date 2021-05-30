import Fluent
import Foundation

// final class RacingWeekRacingTrackPivot: Model {
//     static let schema = "racingweekracingtrackpivot"
    
//     @ID
//     var id: UUID?
    
//     @Parent(key: "weekid")
//     var week: RacingWeek
    
//     @Parent(key: "trackid")
//     var track: RacingTrack
    
//     init() {}
    
//     init(
//         id: UUID? = nil,
//         week: RacingWeek,
//         track: RacingTrack
//     ) throws {
//         self.id = id
//         self.$week.id = try week.requireID()
//         self.$track.id = try track.requireID()
//     }
// }