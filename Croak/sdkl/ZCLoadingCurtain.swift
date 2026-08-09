import Foundation
import UIKit

class ZCLoadingCurtain {
    static let shared = ZCLoadingCurtain()
    private var zcSpinnerView: UIActivityIndicatorView?
    private var zcVeilView: UIView?
    private var zcFadeTicket: DispatchWorkItem?

    private init() {}

    static func zcSpin() {
        guard let zcOverlayWindow = ZCEntryDirector.shared.zcOverlayWindow else { return }

        shared.zcFadeTicket?.cancel()
        shared.zcFadeTicket = nil
        if shared.zcSpinnerView != nil { return }

        let zcShieldView = UIView(frame: zcOverlayWindow.bounds)
        zcShieldView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        zcOverlayWindow.addSubview(zcShieldView)

        let zcSpinnerView = UIActivityIndicatorView(style: .large)
        zcSpinnerView.color = .gray
        zcSpinnerView.center = zcShieldView.center
        zcSpinnerView.startAnimating()
        zcShieldView.addSubview(zcSpinnerView)

        shared.zcSpinnerView = zcSpinnerView
        shared.zcVeilView = zcShieldView
    }

    static func zcToast(_ zcText: String) {
        guard let zcKeyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first(where: { $0.isKeyWindow }) else { return }

        let zcVeilView = UIView()
        zcVeilView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        zcVeilView.layer.cornerRadius = 12
        zcVeilView.clipsToBounds = true

        let zcMessageLabel = UILabel()
        zcMessageLabel.text = zcText
        zcMessageLabel.textColor = .white
        zcMessageLabel.font = .systemFont(ofSize: 15)
        zcMessageLabel.numberOfLines = 0
        zcMessageLabel.textAlignment = .center

        zcVeilView.addSubview(zcMessageLabel)
        zcKeyWindow.addSubview(zcVeilView)

        zcMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        zcVeilView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            zcMessageLabel.topAnchor.constraint(equalTo: zcVeilView.topAnchor, constant: 12),
            zcMessageLabel.bottomAnchor.constraint(equalTo: zcVeilView.bottomAnchor, constant: -12),
            zcMessageLabel.leadingAnchor.constraint(equalTo: zcVeilView.leadingAnchor, constant: 16),
            zcMessageLabel.trailingAnchor.constraint(equalTo: zcVeilView.trailingAnchor, constant: -16),
            zcVeilView.centerXAnchor.constraint(equalTo: zcKeyWindow.centerXAnchor),
            zcVeilView.centerYAnchor.constraint(equalTo: zcKeyWindow.centerYAnchor),
            zcVeilView.leadingAnchor.constraint(greaterThanOrEqualTo: zcKeyWindow.leadingAnchor, constant: 40),
            zcVeilView.trailingAnchor.constraint(lessThanOrEqualTo: zcKeyWindow.trailingAnchor, constant: -40)
        ])

        zcVeilView.alpha = 0

        UIView.animate(withDuration: 0.25) {
            zcVeilView.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.25, animations: {
                zcVeilView.alpha = 0
            }) { _ in
                zcVeilView.removeFromSuperview()
            }
        }
    }

    static func zcFadeSpin() {
        shared.zcFadeTicket?.cancel()

        let zcWorkItem = DispatchWorkItem {
            zcClearSpin()
        }
        shared.zcFadeTicket = zcWorkItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: zcWorkItem)
    }

    static func zcClearSpin() {
        shared.zcFadeTicket?.cancel()
        shared.zcFadeTicket = nil
        shared.zcSpinnerView?.stopAnimating()
        shared.zcVeilView?.removeFromSuperview()
        shared.zcSpinnerView = nil
        shared.zcVeilView = nil
    }
}
