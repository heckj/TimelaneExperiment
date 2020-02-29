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
            Form {
                HStack {
                    Text("User:")
                    TextField("username", text: $model.username)
                }
                if self.model.networkActivity {
                    ActivityIndicator(isAnimating: self.$model.networkActivity, style: .large)
                }
                HStack {
                    Text("Found: ")
                    Text(String(model.githubUserData.count))
                }
            }
            Spacer()
            List(model.githubUserData, id: \.self) { user in
                VStack {
                    HStack {
                        Image(uiImage: self.model.githubUserAvatar)
                            .resizable()
                            .frame(width: 64.0, height: 64.0)
                        Text(user.login)
                        Text("repos: \(user.public_repos)")
                    }
                    Text(user.avatar_url)
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
