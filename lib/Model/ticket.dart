class Ticket {
  // notifyNumber is equal to ticketID
  final String notifyNumber, boardingLocation, destination, date;
  final String ticketID, numberOfPassenger;
  final int status;
  final bool notified;

  Ticket(
      {this.notifyNumber,
      this.notified,
      this.numberOfPassenger,
      this.ticketID,
      this.date,
      this.boardingLocation,
      this.destination,
      this.status});
}
