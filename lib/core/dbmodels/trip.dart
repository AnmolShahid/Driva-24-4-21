class Trip{
  String tripID;
  String destination_address;
  double destination_latitude;
  double destination_longitude;
  String driver_id;
  String pickup_address;
  double pickup_latitude;
  double pickup_longitude;
  String payment_method;
  String request_to;
  int request_to_status;
  String rider_id;
  String rider_name;
  String rider_phone;

  int status;
  int tag;

  String driver_name;
  String driver_phone;

  
  String driver_latitude;
  String driver_longitude;

  String total_EstimatedFare;
  String base_EstimatedFare;
  String distance_EstimatedFare;
  String time_EstimatedFare;
  String distance;
  int feedback_to_driver;
  String ride_start;
  String ride_end;
  int feedback_to_customer;
  int complaintByDriver;
  int complaintByCustomer;

  Trip({
    this.tripID,
    this.feedback_to_driver,
    this.feedback_to_customer,
    this.destination_address,
    this.destination_latitude,
    this.destination_longitude,
    this.driver_id,
    this.pickup_address,
    this.pickup_latitude,
    this.pickup_longitude,
    this.payment_method,
    this.request_to,
    this.request_to_status,
    this.rider_id,
    this.rider_phone,
    this.rider_name,
    this.status,
    this.tag,
    this.driver_name,
    this.driver_phone,
    this.driver_latitude,
    this.driver_longitude,
    this.total_EstimatedFare,
    this.base_EstimatedFare,
    this.distance_EstimatedFare,
    this.time_EstimatedFare,
    this.distance,
    this.ride_start,
    this.ride_end,
    this.complaintByDriver,
    this.complaintByCustomer,
  });
}