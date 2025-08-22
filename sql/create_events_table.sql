-- BigQuery DDL for Live Events Table
-- Creates a table to store live event information

CREATE TABLE `live_events.events` (
  id INT64 NOT NULL,
  event_name STRING NOT NULL,
  start_time_utc TIMESTAMP NOT NULL,
  event_duration INT64 NOT NULL,
  extra_time INT64 DEFAULT 0,
  spend FLOAT64 DEFAULT 0.0
)
PARTITION BY DATE(start_time_utc)
CLUSTER BY event_name
OPTIONS (
  description = 'Table storing live event information including timing and duration details',
  labels = [('environment', 'production'), ('application', 'live-events')]
);

-- Optional: Create indexes for better query performance
-- Note: BigQuery automatically optimizes queries, but clustering helps with performance
