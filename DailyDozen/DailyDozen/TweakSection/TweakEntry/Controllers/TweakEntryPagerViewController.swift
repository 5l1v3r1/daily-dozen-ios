//
//  TweakEntryPagerViewController.swift
//  DailyDozen
//
//  Copyright © 2017 Nutritionfacts.org. All rights reserved.
//

import UIKit
import SimpleAnimation

// MARK: - Builder

class TweakEntryPagerBuilder {

    // MARK: - Methods
    /// Instantiates and returns the initial view controller for a storyboard.
    ///
    /// - Returns: The initial view controller in the storyboard.
    static func instantiateController() -> UIViewController {
        let storyboard = UIStoryboard(name: "TweakEntryPagerLayout", bundle: nil)
        guard
            let viewController = storyboard.instantiateInitialViewController()
            else { fatalError("Did not instantiate `TweakEntryPagerViewController`") }

        return viewController
    }
}

// MARK: - Controller
class TweakEntryPagerViewController: UIViewController {

    // MARK: - Properties
    private var currentDate = DateManager.currentDatetime() {
        didSet {
            LogService.shared.debug("@DATE \(currentDate.datestampKey) TweakEntryPagerViewController")
            if currentDate.isInCurrentDayWith(DateManager.currentDatetime()) {
                backButton.superview?.isHidden = true
                dateButton.setTitle(NSLocalizedString("dateButtonTitle.today", comment: "Date button 'Today' title"), for: .normal)
            } else {
                backButton.superview?.isHidden = false
                dateButton.setTitle(datePicker.date.dateString(for: .long), for: .normal)
            }
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var dateButton: UIButton! {
        didSet {
            dateButton.layer.borderWidth = 1
            dateButton.layer.borderColor = dateButton.titleColor(for: .normal)?.cgColor
            dateButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.maximumDate = DateManager.currentDatetime() // today
            
            if #available(iOS 13.4, *) {
                // Compact style with overlay
                datePicker.preferredDatePickerStyle = .compact
                // After mode and style are set apply UIView sizeToFit().
                datePicker.sizeToFit()
            }
        }
    }

    @IBOutlet private weak var backButton: UIButton!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.tintColor = UIColor.white

        title = NSLocalizedString("navtab.tweaks", comment: "21 Tweaks (proper noun) navigation tab")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.navigationBar.barTintColor = UIColor.greenColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    // MARK: - Methods
    /// Updates UI for the current date.
    ///
    /// - Parameter date: The current date.
    func updateDate(_ date: Date) {
        currentDate = date
        datePicker.setDate(date, animated: false)

        guard let viewController = children.first as? TweakEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(date: currentDate)
    }

    // MARK: - Actions
    @IBAction private func dateButtonPressed(_ sender: UIButton) {
        datePicker.isHidden = false
        datePicker.maximumDate = DateManager.currentDatetime() // today
        dateButton.isHidden = true
    }

    @IBAction private func dateChanged(_ sender: UIDatePicker) {
        dateButton.isHidden = false
        datePicker.isHidden = true
        datePicker.maximumDate = DateManager.currentDatetime() // today
        currentDate = datePicker.date

        guard let viewController = children.first as? TweakEntryViewController else { return }
        viewController.view.fadeOut().fadeIn()
        viewController.setViewModel(date: datePicker.date)
    }

    @IBAction private func viewSwiped(_ sender: UISwipeGestureRecognizer) {
        let today = DateManager.currentDatetime()
        let interval = sender.direction == .left ? -1 : 1
        guard let swipedDate = datePicker.date.adding(.day, value: interval), 
              swipedDate <= today 
        else { return }

        datePicker.setDate(swipedDate, animated: false)
        datePicker.maximumDate = DateManager.currentDatetime() // today
        currentDate = datePicker.date

        guard let viewController = children.first as? TweakEntryViewController else { return }

        if sender.direction == .left {
            viewController.view.slideOut(x: -view.frame.width).slideIn(x: view.frame.width)
        } else {
            viewController.view.slideOut(x: view.frame.width).slideIn(x: -view.frame.width)
        }

        viewController.setViewModel(date: datePicker.date)
    }

    @IBAction private func backButtonPressed(_ sender: UIButton) {
        updateDate(DateManager.currentDatetime())
    }
}
