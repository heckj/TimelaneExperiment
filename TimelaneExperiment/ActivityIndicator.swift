//
//  ActivityIndicator.swift
//  TimelaneExperiment
//
//  Created by Joseph Heck on 2/29/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

#if DEBUG
struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ActivityIndicator(isAnimating: .constant(true), style: .medium)
            ActivityIndicator(isAnimating: .constant(false), style: .medium)
            ActivityIndicator(isAnimating: .constant(true), style: .large)
            ActivityIndicator(isAnimating: .constant(false), style: .large)
        }
    }
}
#endif
