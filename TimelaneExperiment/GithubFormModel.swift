//
//  GithubFormModel.swift
//
//  Created by Joseph Heck on 2/5/20.
//  Copyright © 2020 SwiftUI-Notes. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

import TimelaneCombine

class GithubFormModel : ObservableObject {

    @Published var username: String = "" {
        didSet {
            usernamePublisher.send(self.username)
        }
    }
    private let usernamePublisher = CurrentValueSubject<String, Never>("")

    @Published var githubUserData: [GithubAPIUser] = []
    @Published var githubUserAvatar: UIImage = UIImage()
    @Published var networkActivity = false

    private var myBackgroundQueue: DispatchQueue = DispatchQueue(label: "myBackgroundQueue")
    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        _ = usernamePublisher
            .receive(on: myBackgroundQueue)
            .throttle(for: 0.5, scheduler: myBackgroundQueue, latest: true)
            // ^^ scheduler myBackGroundQueue publishes resulting elements
            // into that queue, resulting on this processing moving off the
            // main runloop.
            .removeDuplicates()
            .print("username pipeline: ") // debugging output for pipeline
            .lane("username")
            .map { username -> AnyPublisher<[GithubAPIUser], Never> in
                return GithubAPI.retrieveGithubUser(username: username)
            }
            // ^^ type returned in the pipeline is a Publisher, so we use
            // switchToLatest to flatten the values out of that
            // pipeline to return down the chain, rather than returning a
            // publisher down the pipeline.
            .lane("githubUserData")
            .switchToLatest()
            // using a sink to get the results from the API search lets us
            // get not only the user, but also any errors attempting to get it.
            .receive(on: RunLoop.main)
            .assign(to: \.githubUserData, on: self)
            .store(in: &cancellableSet)

        let _ = $githubUserData
            .receive(on: myBackgroundQueue)
            .lane("github user data")
            .map { userData -> AnyPublisher<UIImage, Never> in
                guard let firstUser = userData.first else {
                    // my placeholder data being returned below is an empty
                    // UIImage() instance, which simply clears the display.
                    // Your use case may be better served with an explicit
                    // placeholder image in the event of this error condition.
                    return Just(UIImage()).eraseToAnyPublisher()
                }
                return URLSession.shared.dataTaskPublisher(for: URL(string: firstUser.avatar_url)!)
                    // ^^ this hands back (Data, response) objects
                    .handleEvents(receiveSubscription: { _ in
                        DispatchQueue.main.async {
                            self.networkActivity = true
                        }
                    }, receiveCompletion: { _ in
                        DispatchQueue.main.async {
                            self.networkActivity = false
                        }
                    }, receiveCancel: {
                        DispatchQueue.main.async {
                            self.networkActivity = false
                        }
                    })
                    .map { $0.data }
                    // ^^ pare down to just the Data object
                    .map { UIImage(data: $0)!}
                    // ^^ convert Data into a UIImage with its initializer
                    .catch { err in
                        return Just(UIImage())
                    }
                    // ^^ deal the failure scenario and return my "replacement"
                    // image for when an avatar image either isn't available or
                    // fails somewhere in the pipeline here.
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            // ^^ Take the returned publisher that's been passed down the chain
            // and "subscribe it out" to the value within in, and then pass
            // that further down.
            .lane("github avatar image")
            .receive(on: RunLoop.main)
            // ^^ and then switch to receive and process the data on the main
            // queue since we're messing with the UI
            .assign(to: \.githubUserAvatar, on: self)
            .store(in: &cancellableSet)
    }
}
