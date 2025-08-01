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
        completion: ((UserData?, (any Error)?) -> ())?
    ) {
        
        print("Fetching UserData from cloud...");
        
        let auth = Auth.auth()
        
        let firestore = Firestore.firestore()
        let userDocumentReference = firestore.document(
            "users/\(auth.currentUser!.uid)")
        
        userDocumentReference.getDocument { document, error in
            switch (document, error) {
            case (let document?, nil):
                if document.exists {
                    do {
                        print("Found UserData from cloud.");
                        completion?(try document.data(as: UserData.self), nil)
                        return
                    }
                    catch {
                        print("Failed UserData parse.");
                        completion?(nil, error)
                        return
                    }
                }
                else {
                    print("Found empty UserData from cloud.");
                    completion?(UserData(), nil)
                    return
                }
            case (nil, let error?):
                print("Failed document parse.");
                completion?(nil, error)
                return
            default:
                preconditionFailure()
            }
        }
    }
    
    public static func cloudSet(
        _ userData: UserData,
        completion: (((any Error)?) -> ())? = nil
    ) throws {
        
        print("Sending UserData to cloud...");

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
                    DispatchQueue.main.async {
                        cloudData = previousCloudData
                    }
                    print("Failed to send UserData to cloud.");
                    completion?(error)
                    return
                }
                else {
                    print("Sent UserData to cloud.");
                    completion?(nil)
                    return
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
        let result = UserData()
        result.tasks = self.tasks.map { task in task.clone() }
        return result;
    }
}
