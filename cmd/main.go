package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"cloud.google.com/go/bigquery"
	"google.golang.org/api/iterator"
)

// Event represents a live event record from the BigQuery table
type Event struct {
	ID            int64     `bigquery:"id" json:"id"`
	EventName     string    `bigquery:"event_name" json:"event_name"`
	StartTimeUTC  time.Time `bigquery:"start_time_utc" json:"start_time_utc"`
	EventDuration int64     `bigquery:"event_duration" json:"event_duration"`
	ExtraTime     int64     `bigquery:"extra_time" json:"extra_time"`
	Spend         float64   `bigquery:"spend" json:"spend"`
	EndTimeUTC    time.Time // Calculated field: StartTimeUTC + EventDuration + ExtraTime
}

// GetEndTime calculates the actual end time including extra time
func (e *Event) GetEndTime() time.Time {
	totalDuration := time.Duration(e.EventDuration+e.ExtraTime) * time.Minute
	return e.StartTimeUTC.Add(totalDuration)
}

// IsActive checks if the event is active at the given time
func (e *Event) IsActive(checkTime time.Time) bool {
	return checkTime.After(e.StartTimeUTC) && checkTime.Before(e.EndTimeUTC)
}

func main() {
	ctx := context.Background()

	// Get project ID from environment variable
	projectID := os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal("GOOGLE_CLOUD_PROJECT environment variable must be set")
	}

	// Create BigQuery client
	client, err := bigquery.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create BigQuery client: %v", err)
	}
	defer client.Close()

	// Query to select all events
	query := client.Query(`
		SELECT 
			id,
			event_name,
			start_time_utc,
			event_duration,
			extra_time,
			spend
		FROM ` + "`live_events.events`" + `
		ORDER BY start_time_utc
	`)

	// Execute the query
	it, err := query.Read(ctx)
	if err != nil {
		log.Fatalf("Failed to execute query: %v", err)
	}

	fmt.Println("Live Events:")
	fmt.Println("============")

	var events []Event
	for {
		var event Event
		err := it.Next(&event)
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Fatalf("Failed to read row: %v", err)
		}

		// Calculate EndTimeUTC
		totalDuration := time.Duration(event.EventDuration+event.ExtraTime) * time.Minute
		event.EndTimeUTC = event.StartTimeUTC.Add(totalDuration)

		events = append(events, event)
		
		// Display event information
		fmt.Printf("ID: %d\n", event.ID)
		fmt.Printf("Event: %s\n", event.EventName)
		fmt.Printf("Start Time: %s\n", event.StartTimeUTC.Format("2006-01-02 15:04:05 UTC"))
		fmt.Printf("Duration: %d minutes\n", event.EventDuration)
		fmt.Printf("Extra Time: %d minutes\n", event.ExtraTime)
		fmt.Printf("End Time: %s\n", event.EndTimeUTC.Format("2006-01-02 15:04:05 UTC"))
		fmt.Printf("Spend: $%.2f\n", event.Spend)
		fmt.Println("---")
	}

	fmt.Printf("\nTotal events loaded: %d\n", len(events))

	// Example: Check which events are active at a specific time
	checkTime := time.Date(2025, 9, 1, 14, 30, 0, 0, time.UTC)
	fmt.Printf("\nEvents active at %s:\n", checkTime.Format("2006-01-02 15:04:05 UTC"))
	
	activeCount := 0
	for _, event := range events {
		if event.IsActive(checkTime) {
			fmt.Printf("- %s (ID: %d)\n", event.EventName, event.ID)
			activeCount++
		}
	}
	
	if activeCount == 0 {
		fmt.Println("No events are active at this time.")
	}
}
