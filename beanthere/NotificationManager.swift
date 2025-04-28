//
//  NotificationManager.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 4/27/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private var reviewListeners: [String: ListenerRegistration] = [:]
    private var friendReviewCounts: [String: Int] = [:]
    private var friendIds: [String] = []
    
    private init() {}
    
    func startListeningIfNeeded() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    self.startListeningForFriendReviews(userId: currentUserId)
                }
            } else {
                print("Notifications not authorized.")
            }
        }
    }
    
    private func startListeningForFriendReviews(userId: String) {
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(userId)
        
        userDoc.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("User document is empty.")
                return
            }
            
            self.friendIds = data["friendsList"] as? [String] ?? []
            
            if self.friendIds.isEmpty {
                print("No friends found.")
                return
            }
            
            print("Friend IDs: \(self.friendIds)")
            
            for friendId in self.friendIds {
                let listener = db.collection("users").document(friendId)
                    .addSnapshotListener { snapshot, error in
                        guard let snapshot = snapshot else {
                            print("Error fetching friend document: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        let reviews = snapshot.data()?["reviews"] as? [String] ?? []
                        let currentCount = reviews.count
                        let previousCount = self.friendReviewCounts[friendId] ?? 0
                        
                        if currentCount > previousCount {
                            self.sendLocalNotification()
                            print("New review detected for friend \(friendId)")
                        }
                        
                        self.friendReviewCounts[friendId] = currentCount
                    }
                
                self.reviewListeners[friendId] = listener
            }
        }
    }
    
    private func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "New Friend Review!"
        content.body = "One of your friends posted a new review ☕️"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to add notification: \(error.localizedDescription)")
            }
        }
    }
    
    func stopListening() {
        for (_, listener) in reviewListeners {
            listener.remove()
        }
        reviewListeners.removeAll()
    }
}
