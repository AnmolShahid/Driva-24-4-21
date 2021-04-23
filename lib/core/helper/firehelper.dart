import 'package:flutter_app/core/dbmodels/nearbyDrivers.dart';

class FireHepler{

  static List<NearbyDrivers> nearbyDriverList = [];


  static void removeFromList(String key){

    int index = nearbyDriverList.indexWhere((element) => element.key == key);
    nearbyDriverList.removeAt(index);

  }

  static void updateNearbyLocation(NearbyDrivers driver){
    int index = nearbyDriverList.indexWhere((element) => element.key == driver.key);
    
    nearbyDriverList[index].latitude = driver.latitude;
    nearbyDriverList[index].longitude = driver.longitude;
  }

   static String getNearbyDriver(){
    return nearbyDriverList[0].key;
  }

  static double getDriverLatitude(key){
    return nearbyDriverList[0].latitude;
  }

    static double getDriverLongitude(key){
    return nearbyDriverList[0].longitude;
  }
}