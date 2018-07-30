//
//  LocationUtils.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/24/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import MapKit

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension CLLocation {
    
    public func concatenatedMagnitudes() -> String {
        let latitude = String(format: "%.4f", self.coordinate.latitude)
        let longitude = String(format: "%.4f", self.coordinate.longitude)
        return latitude + longitude
    }
    
}

public struct LocationUtils {
    
    public static let earthRadiusKM = 6371.0
    
    // Given a center, return all the possible points in diameterMT, with gpsCoordIncrements accuracy
    // For gps accuracy please read: https://gis.stackexchange.com/questions/8650/measuring-accuracy-of-latitude-and-longitude
    public static func allPossiblePoints(center: CLLocation, diameterMT: Double, gpsCoordIncrements: Double) -> [CLLocation] {
        let coordsIncrement = gpsCoordIncrements
        let distance = diameterMT
        let radius = LocationUtils.earthRadiusKM
        let quotient = (distance/radius).radiansToDegrees;
        let lat = Double.init(String.init(format: "%.4f", center.coordinate.latitude))!
        let lon = Double.init(String.init(format: "%.4f", center.coordinate.longitude))!
        let maxLat = lat + quotient;
        let minLat = lat - quotient;
        let maxLon = lon + quotient;
        let minLon = lon - quotient;
        
        var latList = [CLLocationDegrees]();
        var lonList = [CLLocationDegrees]();
        var currentLat = minLat;
        var currentLon = minLon;
        var coordList = [CLLocation]();
        
        while(currentLat <= maxLat) {
            latList.append(currentLat);
            currentLat += coordsIncrement;
        }
        
        while(currentLon <= maxLon) {
            lonList.append(currentLon);
            currentLon += coordsIncrement;
        }
        
        for latitude in latList {
            for longitude in lonList {
                let pointLat = Double.init(String.init(format: "%.4f", latitude))!
                let pointLon = Double.init(String.init(format: "%.4f", longitude))!
                coordList.append(CLLocation.init(latitude: pointLat, longitude: pointLon))
            }
        }
        
        return coordList;
    }
    
    // Return must always have 4 points
    public static func generateHintQuadrant(center: CLLocation, sideDistance: Double) -> [CLLocation] {
        let distance = sideDistance
        let radius = LocationUtils.earthRadiusKM
        let quotient = (distance/radius).radiansToDegrees;
        let lat = center.coordinate.latitude
        let lon = center.coordinate.longitude
        let maxLat = lat + quotient;
        let minLat = lat - quotient;
        let maxLon = lon + quotient;
        let minLon = lon - quotient;
        
        let point1 = CLLocation.init(latitude: minLat, longitude: minLon)
        let point2 = CLLocation.init(latitude: minLat, longitude: maxLon)
        let point3 = CLLocation.init(latitude: maxLat, longitude: minLon)
        let point4 = CLLocation.init(latitude: maxLat, longitude: maxLon)

        return [point1, point2, point3, point4]
    }
    
    // As long as the points are close enough and in a regular shape (square and rect) this should work
    public static func getRegularCentroid(points: [CLLocation]) -> CLLocation {
        let sumLat = points.reduce(into: 0.0) { (result, currPoint) in
            result += currPoint.coordinate.latitude.magnitude
        }
        let sumLon = points.reduce(into: 0.0) { (result, currPoint) in
            result += currPoint.coordinate.longitude.magnitude
        }
        let avgLat = sumLat/4
        let avgLon = sumLon/4
        return CLLocation.init(latitude: avgLat, longitude: avgLon)
    }
    
    // Returns the distance in meters
    public static func questDistanceToPlayerLocation(quest: Quest, playerLocation: CLLocation) -> CLLocationDistance {
        let hintQuadrantCenterPoint = getRegularCentroid(points: quest.getQuadranHintCorners())
        return playerLocation.distance(from: hintQuadrantCenterPoint)
    }
    
    // Credit to: https://stackoverflow.com/questions/38326875/how-to-place-annotations-randomly-in-mapkit-swift
    public static func generateRandomCoordinates(currentLoc: CLLocation, min: UInt32, max: UInt32) -> CLLocation {
        //Get the Current Location's longitude and latitude
        let currentLong = currentLoc.coordinate.longitude
        let currentLat = currentLoc.coordinate.latitude
        
        //1 KiloMeter = 0.00900900900901° So, 1 Meter = 0.00900900900901 / 1000
        let meterCord = 0.00900900900901 / 1000
        
        //Generate random Meters between the maximum and minimum Meters
        let randomMeters = UInt(arc4random_uniform(max) + min)
        
        //then Generating Random numbers for different Methods
        let randomPM = arc4random_uniform(6)
        
        //Then we convert the distance in meters to coordinates by Multiplying number of meters with 1 Meter Coordinate
        let metersCordN = meterCord * Double(randomMeters)
        
        //here we generate the last Coordinates
        if randomPM == 0 {
            return CLLocation(latitude: currentLat + metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 1 {
            return CLLocation(latitude: currentLat - metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 2 {
            return CLLocation(latitude: currentLat + metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 3 {
            return CLLocation(latitude: currentLat - metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 4 {
            return CLLocation(latitude: currentLat, longitude: currentLong - metersCordN)
        }else {
            return CLLocation(latitude: currentLat - metersCordN, longitude: currentLong)
        }
    }
}
