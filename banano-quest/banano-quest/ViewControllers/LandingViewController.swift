//
//  LandingViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import Pocket
import CoreData

class LandingViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func refreshView() throws {
        print("LandingViewController - refreshView()")
    }

    func launchQuesting() {
        do {
            try _ = Player.getPlayer(context: CoreDataUtil.mainPersistentContext)
        } catch PlayerPersistenceError.retrievalError {
            // Player doesn't exist, redirect to wallet creation flow
            launchWalletCreation()
            return
        } catch {
            // Show error
            self.present(self.bananoAlertView(title: "Error", message: "Error loading your account, please try again"), animated: true, completion: nil)
            print("\(error)")
            return
        }

        do {
            let vc = try self.instantiateViewController(identifier: "ContainerVC", storyboardName: "Questing") as? ContainerViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        }catch let error as NSError {
            // Show error
            self.present(self.bananoAlertView(title: "Error", message: "Error loading quests, please try again"), animated: true, completion: nil)
            print("\(error)")
            return
        }
    }

    func launchWalletCreation() {
        do {
            let vc = try self.instantiateViewController(identifier: "AccountCreationViewController", storyboardName: "CreateAccount") as? NewWalletViewController

            self.navigationController?.pushViewController(vc!, animated: false)
        }catch let error as NSError {
            print("Failed to instantiate NewWalletViewController with error: \(error)")
        }
    }

    func launchOnboarding() {
        // Instantiate onboarding storyboard flow
        do {
            guard let onboardingVC = try self.instantiateViewController(identifier: "OnboardingViewController", storyboardName: "Onboarding") as? OnboardingViewController else {
                return
            }

            onboardingVC.completionHandler = {
                onboardingVC.dismiss(animated: true, completion: nil)
                self.processNavigation()
            }

            self.navigationController?.present(onboardingVC, animated: true, completion: nil)
        } catch {
            print("Error displaying onboarding")
        }
    }

    func processNavigation() {
        if AppConfiguration.displayedOnboarding() {
            launchQuesting()
        } else {
            launchOnboarding()
        }
    }

    // MARK: - Actions
    @IBAction func playNowPressed(_ sender: Any) {
        processNavigation()
    }

}
