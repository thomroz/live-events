-- Sample data for Live Events Table
-- Test cases for analyzing live events at 45 minutes past the hour
-- All events on Sept 01, 2025 with 15-minute extra_time allowance
-- Events ordered by start_time_utc with sequential IDs

-- Test Case 6: Multiple overlapping events in same hour
-- All three events overlap during 08:00-09:00 hour
-- footballMorning: 07:30-09:00 + 15min = ends at 09:15
INSERT INTO `live_events.events` (id, event_name, start_time_utc, event_duration, extra_time, spend)
VALUES (1, 'footballMorning', '2025-09-01 07:30:00', 90, 15, 2800.00);

-- soccerMorning: 08:15-09:30 + 15min = ends at 09:45
INSERT INTO `live_events.events` (id, event_name, start_time_utc, event_duration, extra_time, spend)
VALUES (2, 'soccerMorning', '2025-09-01 08:15:00', 75, 15, 2300.00);

-- tennisMorning: 08:45-09:45 + 15min = ends at 10:00
INSERT INTO `live_events.events` (id, event_name, start_time_utc, event_duration, extra_time, spend)
VALUES (3, 'tennisMorning', '2025-09-01 08:45:00', 60, 15, 1600.00);

-- Test Case 1: Isolated event (no overlap/consecutive events)
-- Tennis: 10:00-11:00 + 15min = ends at 11:15
-- Analysis at 11:45 should find NO events in upcoming hour (12:00-13:00)
INSERT INTO `live_events.events` (id, event_name, start_time_utc, event_duration, extra_time, spend)
VALUES (4, 'tennis', '2025-09-01 10:00:00', 60, 15, 1500.00);

-- Test Case 2: Overlapping events
-- Hockey: 13:30-15:00 + 15min = ends at 15:15
-- Analysis at 13:45 should find BOTH events active in upcoming hour (14:00-15:00)
INSERT INTO `live_events.events` (id, event_name, start_time_utc, event_duration, extra_time, spend)
VALUES (5, 'hockey', '2025-09-01 13:30:00', 90, 15, 2200.00);

-- Football: 14:45-16:15 + 15min = ends at 16:30
INSERT INTO `live_events.events` (id, event_name, start_time_utc, event_duration, extra_time, spend)
VALUES (6, 'football', '2025-09-01 14:45:00', 90, 15, 3000.00);

-- Test Case 3: Consecutive events (back-to-back)
-- Soccer: 17:00-18:30 + 15min = ends at 18:45
-- Analysis at 17:45 should find soccer active in upcoming hour (18:00-19:00)
INSERT INTO `live_events.events` (id, event_name, start_time_utc, event_duration, extra_time, spend)
VALUES (7, 'soccer', '2025-09-01 17:00:00', 90, 15, 2500.00);

-- Test Case 4: Event starting exactly at the analysis time
-- Analysis at 19:45, event starts at 20:00
INSERT INTO `live_events.events` (id, event_name, start_time_utc, event_duration, extra_time, spend)
VALUES (8, 'tennisNight', '2025-09-01 20:00:00', 75, 15, 1800.00);

-- Test Case 5: Event ending exactly at start of analysis hour
-- Event ends at 22:00, analysis at 21:45 for hour 22:00-23:00
INSERT INTO `live_events.events` (id, event_name, start_time_utc, event_duration, extra_time, spend)
VALUES (9, 'hockeyEvening', '2025-09-01 20:30:00', 75, 15, 2100.00);

/*
Test Scenarios Summary (ordered by start_time_utc):
- Analysis Time: XX:45 (45 minutes past any hour)
- Check: Upcoming hour (XX+1:00 to XX+2:00) for ANY live events

ID 1-3: 07:45 analysis → 08:00-09:00 hour: multiple overlapping events
  1. footballMorning (07:30-09:15)
  2. soccerMorning (08:15-09:45) 
  3. tennisMorning (08:45-10:00)

ID 4: 11:45 analysis → 12:00-13:00 hour: NO events (isolated case)
  4. tennis (10:00-11:15)

ID 5-6: 13:45 analysis → 14:00-15:00 hour: hockey + football overlap
  5. hockey (13:30-15:15)
  6. football (14:45-16:30)

ID 7: 17:45 analysis → 18:00-19:00 hour: soccer active
  7. soccer (17:00-18:45)

ID 8: 19:45 analysis → 20:00-21:00 hour: tennisNight starts exactly at 20:00
  8. tennisNight (20:00-21:15)

ID 9: 21:45 analysis → 22:00-23:00 hour: hockeyEvening ends exactly at 22:00
  9. hockeyEvening (20:30-21:45)

Event end time calculation: start_time_utc + event_duration + extra_time
*/
