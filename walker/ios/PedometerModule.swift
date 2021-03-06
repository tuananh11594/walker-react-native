//
//  PedometerManager.swift
//  walker
//
//  Created by Tuan Anh on 8/1/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

@objc(PedometerModule)
class PedometerModule: RCTEventEmitter {
  static let sharedInstance = RCTEventEmitter()
  private let activityManager = CMMotionActivityManager()
  private let pedometer = CMPedometer()
  private var startDate: Date? = nil
  
  private override init() {}
  
  // Returns an array of your named events
  override func supportedEvents() -> [String]! {
    return ["Pedometer"]
  }
  
  @objc func onStart() {
    print("Start pedometer")
    startDate = Date()
    checkAuthorizationStatus()
    startUpdating()
  }
  
  @objc func onStop() {
    print("Stop pedometer")
    startDate = nil
    stopUpdating()
  }
  
  @objc func startCountingSteps() {
    pedometer.startUpdates(from: Date()) {
      [weak self] (pedometerData, error) in
      guard let pedometerData = pedometerData, error == nil else { return }
      DispatchQueue.main.async {

//        callback([error])
        self?.sendEvent(withName: "Pedometer", body: pedometerData.numberOfSteps.stringValue)
        print("Counting Steps: " + pedometerData.numberOfSteps.stringValue)
      }
    }
  }
  
  private func startUpdating() {
    if CMMotionActivityManager.isActivityAvailable() {
      startTrackingActivityType()
    } else {
      print("Pedometer is not available")
    }
    
    if CMPedometer.isStepCountingAvailable() {
//      startCountingSteps()
    } else {
      print("Pedometer is not available")
    }
  }
  
  private func stopUpdating() {
    activityManager.stopActivityUpdates()
    pedometer.stopUpdates()
    if #available(iOS 10.0, *) {
      pedometer.stopEventUpdates()
    } else {
      // Fallback on earlier versions
      print("function stopEventUpdates is only iOS 10.0 or later")
    }
  }
  
  private func on(error: Error) {
    //handle error
  }
  
  private func checkAuthorizationStatus() {
    if #available(iOS 11.0, *) {
      switch CMMotionActivityManager.authorizationStatus() {
      case CMAuthorizationStatus.denied:
        onStop()
        break
      default: break
      }
    } else {
      // Fallback on earlier versions
      print("function authorizationStatus is only iOS 10.0 or later")
    }
  }
  
  private func startTrackingActivityType() {
    activityManager.startActivityUpdates(to: OperationQueue.main) {
      [weak self](activity: CMMotionActivity?) in
      guard let activity = activity else { return }
      DispatchQueue.main.async {
        if activity.walking {
          print("Walking")
        } else if activity.stationary {
          print("Stationary")
        } else if activity.running {
          print("Running")
        } else if activity.automotive {
          print("Automotive")
        }
      }
    }
  }
  
}
