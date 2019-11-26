//
//  CloudKitError.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 10/18/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import Foundation
import CloudKit

struct CloudKitError {
    func handle_CKError(ckError: CKError.Code){
        switch ckError{
        case .alreadyShared:
            print("CKError: Record or share cannot be saved because doing so would cause the same hierarchy of records to exist in multiple shares.")
            break
        case .assetFileModified:
            print("CKError: The content of the specified asset file was modified while being saved.")
            break
        case .assetFileNotFound:
            print("CKError: The specified asset file is not found.")
            break
        case .badContainer:
            print("CKError: The specified container is unknown or unauthorized.")
            break
        case .badDatabase:
            print("CKError: The operation could not be completed on the given database.")
            break
        case .batchRequestFailed:
            print("CKError: The entire batch was rejected.")
            break
        case .changeTokenExpired:
            print("CKError: The previous server change token is too old.")
            break
        case .constraintViolation:
            print("CKError: The server rejected the request because of a conflict with a unique field.")
            break
        case .incompatibleVersion:
            print("CKError: Your app version is older than the oldest version allowed.")
            break
        case .internalError:
            print("CKError: A nonrecoverable error encountered by CloudKit.")
            break
        case .invalidArguments:
            print("CKError: Invalid arguments. This request contains bad information.")
            break
        case .limitExceeded:
            print("CKError: Request to the server is too large.")
            break
        case .managedAccountRestricted:
            print("CKError: Request is rejected due to a managed-account restriction.")
            break
        case .missingEntitlement:
            print("CKError: The app is missing a required entitlement.")
            break
        case .networkFailure:
            print("CKError: The network is available but cannot be accessed.")
            break
        case .networkUnavailable:
            print("CKError: The network is not available.")
            break
        case .notAuthenticated:
            print("CKError: The current user is not authenticated, and no user record was available.")
            break
        case .operationCancelled:
            print("CKError: Operation was explicitly canceled.")
            break
        case .partialFailure:
            print("CKError: Some items failed, operation succeeded overall.")
            break
        case .participantMayNeedVerification:
            print("CKError: The user is not a member of the share.")
            break
        case .permissionFailure:
            print("CKError: The user did not have permission to perform the specified save or fetch operation.")
            break
        case .quotaExceeded:
            print("CKError: Saving the record would exceed the user’s current storage quota.")
            break
        case .referenceViolation:
            print("CKError: The target of a record's parent or share reference is not found.")
            break
        case .requestRateLimited:
            print("CKError: Transfers to and from the server are being rate limited for the client at this time.")
            break
        case .serverRecordChanged:
            print("CKError: The record was rejected because the version on the server is different.")
            break
        case .serverRejectedRequest:
            print("CKError: The server rejected the request.")
            break
        case .serverResponseLost:
            print("CKError: Server response lost.")
            break
        case .serviceUnavailable:
            print("CKError: The CloudKit service is unavailable.")
            break
        case .tooManyParticipants:
            print("CKError: Share cannot be saved because too many participants are attached to the share.")
            break
        case .unknownItem:
            print("CKError: The specified record does not exist.")
            break
        case .userDeletedZone:
            print("CKError: The user has deleted this zone from the settings UI.")
            break
        case .zoneBusy:
            print("CKError: The server is too busy to handle the zone operation.")
            break
        case .zoneNotFound:
            print("CKError: The specified record zone does not exist on the server.")
            break
        default:
            print("CKError: deafult error.")
            break
        }
    }
}

