//
//  ViewController.swift
//  Project31
//
//  Created by clarknt on 2019-09-24.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!

    // weak because the user might delete it at any time
    weak var activeWebView: WKWebView?

    var placeholderView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setDefaultTitle()

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
    }

    func setDefaultTitle() {
        title = "Multibrowser"

        // bonus: when there's no view, clear address bar, and disable it
        addressBar.text = ""
        addressBar.isEnabled = false

        // challenge 2
        stackView.addArrangedSubview(getPlaceholderView())
    }

    // challenge 2
    func getPlaceholderView() -> UIView {
        // reuse existing one if available
        guard placeholderView == nil else { return placeholderView! }

        // create label
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Hint: tap the + button to add a browser view."
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        // add it to a view
        placeholderView = UIView()
        placeholderView!.addSubview(placeholderLabel)

        // expand it to fill the view
        placeholderLabel.leadingAnchor.constraint(equalTo: placeholderView!.safeAreaLayoutGuide.leadingAnchor).isActive = true
        placeholderLabel.trailingAnchor.constraint(equalTo: placeholderView!.safeAreaLayoutGuide.trailingAnchor).isActive = true
        placeholderLabel.topAnchor.constraint(equalTo: placeholderView!.safeAreaLayoutGuide.topAnchor).isActive = true
        placeholderLabel.bottomAnchor.constraint(equalTo: placeholderView!.safeAreaLayoutGuide.bottomAnchor).isActive = true

        return placeholderView!
    }

    @objc func addWebView() {
        // challenge 2
        if stackView.arrangedSubviews.count == 1 && stackView.arrangedSubviews[0] == placeholderView {
            if let placeholderView = placeholderView {
                stackView.removeArrangedSubview(placeholderView)
                placeholderView.removeFromSuperview()
            }
        }

        // bonus: reenable address bar when a view is shown
        addressBar.isEnabled = true

        let webView = WKWebView()
        webView.navigationDelegate = self

        // note: with stackView, do no call addSubview(:) but addArrangedSubview(:)
        stackView.addArrangedSubview(webView)

        let url = URL(string: "https://www.apple.com/")!
        webView.load(URLRequest(url: url))

        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }

    func selectWebView(_ webView: WKWebView) {
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }

        activeWebView = webView
        webView.layer.borderWidth = 3

        updateUI(for: webView)
    }

    @objc func webViewTapped(_ recognizer: UIGestureRecognizer) {
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }

    @objc func deleteWebView() {
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.firstIndex(of: webView) {
                // remove from the stackView
                stackView.removeArrangedSubview(webView)

                // but also from the view hierarchy (important - removing from the stack view
                // hids the view but does not destroy it, for optional later reuse)
                webView.removeFromSuperview()

                // no more views: reset title
                if stackView.arrangedSubviews.count == 0 {
                    setDefaultTitle()
                }
                else {
                    var currentIndex = Int(index)

                    // was the last stackView in the stack
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }

                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                        selectWebView(newSelectedWebView)
                    }
                }

            }
        }
    }

    func updateUI(for webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.url?.absoluteString ?? ""
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        }
        else {
            stackView.axis = .horizontal
        }
    }

    // MARK:- WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }

    // MARK:- UIGestureRecognizerDelegate

    // allow tap gesture to be recognized along the the ones built in the webview
    // otherwise the gesture would be captured by the webview only
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK:- UITextFieldDelegate

    // return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webView = activeWebView, var address = addressBar.text {
            // challenge 1
            if !address.starts(with: "http://") && !address.starts(with: "https://") {
                address = "https://" + address
            }

            if let url = URL(string: address) {
                webView.load(URLRequest(url: url))
            }
        }

        // hide the keyboard
        textField.resignFirstResponder()
        return true
    }
}
