//
//  Collage_Finish_Advertisement.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 2/9/20.
//  Copyright © 2020 Brendan Castro. All rights reserved.
//

import UIKit
import GoogleMobileAds

//class Collage_Finish_Advertisement: UIViewController, GADInterstitialDelegate {

extension Collage_Step2 {
    
    //MARK: GAD Setup
    func setupAndReturnAdvert() -> GADInterstitial{
        let interstitial = GADInterstitial(adUnitID: googleAdvertAppID)
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
    
    //MARK: GAD stubs
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      //interstitial = setupAndReturnAdvert()
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      print("interstitialWillDismissScreen")
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
    
    
}
