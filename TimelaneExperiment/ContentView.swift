//
//  ContentView.swift
//  TimelaneExperiment
//
//  Created by Joseph Heck on 2/29/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var model: GithubFormModel

    var body: some View {
        VStack {
            Text("Hello, World!")
            Form {
                HStack {
                    Text("User:")
                    TextField("username", text: $model.username)
                }
                HStack {
                    Text("Found: ")
                    Text(String(model.githubUserData.count))
                }
            }
            Spacer()
            ForEach(model.githubUserData, id: \.self) { user in
                VStack {
                    HStack {
                        Text(user.login)
                        Text("repos: \(user.public_repos)")
                    }
                    Text(user.avatar_url)
                    if self.model.networkActivity {
                        ActivityIndicator(isAnimating: self.$model.networkActivity, style: .large)
                    }
//                    Image(model.githubUserAvatar)
                }
            }

        }

    }
}

#if DEBUG
var ghModel = GithubFormModel()
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: ghModel)
    }
}
#endif
