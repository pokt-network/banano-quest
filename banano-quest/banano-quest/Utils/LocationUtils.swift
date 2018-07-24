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
        let lat = center.coordinate.latitude
        let lon = center.coordinate.longitude
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
                coordList.append(CLLocation.init(latitude: latitude, longitude: longitude))
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
    public static func getRegularCentroid(point1: CLLocation, point2: CLLocation, point3: CLLocation, point4: CLLocation) -> CLLocation {
        let sumLat = [point1, point2, point3, point4].reduce(into: 0.0) { (result, currPoint) in
            result += currPoint.coordinate.latitude.magnitude
        }
        let sumLon = [point1, point2, point3, point4].reduce(into: 0.0) { (result, currPoint) in
            result += currPoint.coordinate.longitude.magnitude
        }
        let avgLat = sumLat/4
        let avgLon = sumLon/4
        return CLLocation.init(latitude: avgLat, longitude: avgLon)
    }
}
