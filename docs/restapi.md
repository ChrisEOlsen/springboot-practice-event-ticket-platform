## Create Event
POST /api/v1/events
Request Body: Event

## List Events (can be reused for staff depending on jwt)
GET /api/v1/events

## Retrieve Event
GET /api/v1/events/{event_id}

## Update Event
PUT /api/v1/events/{event_id}

## Delete Event
DELETE /api/v1/events/{event_id}

## Validate Ticket
POST /api/v1/events/{event_id}/ticket-validations

## List Ticket validations
GET /api/v1/events/{event_id}/ticket-validations

## List Ticket Sales
GET /api/v1/events/{event_id}/tickets

## Retrieve Ticket Sale
GET /api/v1/events/{event_id}/tickets/{ticket_id}

## Partial Update
PATCH /api/v1/events/{event_id}/tickets
Request Body: Partial Ticket

## List Ticket Type
GET /api/v1/events/{event_id}/ticket-types

## Retrieve Ticket Type
GET /api/v1/events/{event_id}/ticket-type/{ticket_type_id}

## Delete Ticket Type
DELETE /api/v1/events/{event_id}/ticket-type/{ticket_type_id}

## Partial Update Ticket Type
PATCH /api/v1/events/{event_id}/ticket-type/{ticket_type_id}
Request Body: Partial Ticket Type

## Search Published Events (maybe refine this)
GET /api/v1/published-events

## Retrieve Published Events
GET /api/v1/published-events/{published_event_id}

## Purchase Ticket
POST /api/v1/published-events/{published_event_id}/ticket-types/{ticket_types_id}

## List Tickets (for user)
GET /api/v1/tickets

## Retrieve Ticket (for user)
GET /api/v1/ticket/{ticket_id}

## Retrieve Ticket QR Code
GET /api/v1/ticket/{ticket_id}/qr-codes

## TODO: Dedicated endpoint for report data


# Staff flow
