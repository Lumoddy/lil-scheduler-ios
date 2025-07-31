//
//  UserData.swift
//  Lil' Scheduler
//
//  Created by 13878 on 29/7/2025.
//

import FirebaseAuth
import FirebaseFirestore

public class UserData : Codable {
    
    public var tasks: [CalendarTask];
    
    public init() {
        self.tasks = []
    }
    
    public static var cloudData: UserData? = nil
    
    public static func cloudGet(
        completion: @escaping (UserData?, (any Error)?) -> ()
    ) {
        
        let auth = Auth.auth()
        
        let firestore = Firestore.firestore()
        let userDocumentReference = firestore.document(
            "users/\(auth.currentUser!.uid)")
        
        userDocumentReference.getDocument { document, error in
            switch (document, error) {
            case (let document?, nil):
                if document.exists {
                    do {
                        return completion(try document.data(as: UserData.self), nil)
                    }
                    catch {
                        return completion(nil, error)
                    }
                }
                else {
                    return completion(UserData(), nil)
                }
                break
            case (nil, let error?):
                return completion(nil, error)
            default:
                return assertionFailure()
            }
        }
    }
    
    public static func cloudSet(
        _ userData: UserData,
        completion: @escaping ((any Error)?) -> ()
    ) throws {
        
        let auth = Auth.auth()
        
        let firestore = Firestore.firestore()
        let userDocumentReference = firestore.document(
            "users/\(auth.currentUser!.uid)")
        
        let previousCloudData = cloudData
        cloudData = userData
        try userDocumentReference.setData(
            from: userData,
            completion: { error in
                if let error = error {
                    cloudData = previousCloudData
                    return completion(error)
                }
                else {
                    return completion(nil)
                }
            })
    }
    
    private enum _Key : CodingKey {
        
        case tasks
        
        public var stringValue: String {
            switch self {
            case .tasks: "tasks"
            }
        }
        
        public init?(stringValue: String) {
            switch stringValue {
            case "tasks":
                self = .tasks
                return
            default:
                return nil
            }
        }
        
        public init?(intValue: Int) { nil }
    }
    
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: _Key.self)
        self.tasks = try container.decode(
            [CalendarTask].self,
            forKey: _Key.tasks)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: _Key.self)
        try container.encode(self.tasks, forKey: _Key.tasks)
    }
    
    public func clone() -> UserData {
        var result = UserData()
        result.tasks = self.tasks.map { task in task.clone() }
        return result;
    }
}
