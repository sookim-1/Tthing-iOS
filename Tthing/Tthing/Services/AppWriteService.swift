//
//  AppWriteService.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation
import Appwrite
import JSONCodable

class AppWriteService {
  static let shared = AppWriteService()

  private let client: Client
  let account: Account
  let tablesDB: TablesDB
  let storage: Storage

  private init() {
    self.client = Client()
      .setEndpoint(AppConfiguration.appWriteEndpoint)
      .setProject(AppConfiguration.appWriteProjectID)

    self.account = Account(client)
    self.tablesDB = TablesDB(client)
    self.storage = Storage(client)
  }

  // MARK: - Auth Methods

  func register(email: String, password: String) async throws -> AppwriteModels.User<[String: AnyCodable]> {
    try await account.create(
      userId: ID.unique(),
      email: email,
      password: password
    )
  }

  func login(email: String, password: String) async throws -> AppwriteModels.Session {

    try await account.createEmailPasswordSession(
      email: email,
      password: password
    )
  }

    func createTarget() async throws {
        let token = PushNotificationService.shared.getDeviceToken() ?? ""
        try await account.createPushTarget(targetId: ID.unique(), identifier: token)

    }

  func loginWithApple(token: String) async throws {
    _ = try await account.createOAuth2Token(
      provider: .apple,
      success: "\(AppConfiguration.bundleID)://auth/success",
      failure: "\(AppConfiguration.bundleID)://auth/failure"
    )
  }

  func logout() async throws {
    try await account.deleteSession(sessionId: "current")
  }

  func getCurrentUser() async throws -> AppwriteModels.User<[String: AnyCodable]> {
    try await account.get()
  }

  func checkSession() async throws -> AppwriteModels.Session {
    try await account.getSession(sessionId: "current")
  }

  // MARK: - Database Methods

  func createRow(
    tableId: String,
    data: [String: Any]
  ) async throws -> Row<[String: AnyCodable]> {
    try await tablesDB.createRow(
      databaseId: AppConfiguration.databaseID,
      tableId: tableId,
      rowId: ID.unique(),
      data: data
    )
  }

  func getRow(
    tableId: String,
    rowId: String
  ) async throws -> Row<[String: AnyCodable]> {
    try await tablesDB.getRow(
      databaseId: AppConfiguration.databaseID,
      tableId: tableId,
      rowId: rowId
    )
  }

  func listRow(
    tableId: String,
    queries: [String]? = nil
  ) async throws -> RowList<[String: AnyCodable]> {
    try await tablesDB.listRows(
      databaseId: AppConfiguration.databaseID,
      tableId: tableId,
      queries: queries
    )
  }

  func updateRow(
    tableId: String,
    rowId: String,
    data: [String: Any]
  ) async throws -> Row<[String: AnyCodable]> {
    try await tablesDB.updateRow(
      databaseId: AppConfiguration.databaseID,
      tableId: tableId,
      rowId: rowId,
      data: data
    )
  }

  func deleteRow(
    tableId: String,
    rowId: String
  ) async throws -> Any {
    try await tablesDB.deleteRow(
      databaseId: AppConfiguration.databaseID,
      tableId: tableId,
      rowId: rowId
    )
  }

  // MARK: - Storage Methods

  func uploadFile(
    fileData: Data,
    fileName: String,
    mimeType: String = "image/jpeg"
  ) async throws -> AppwriteModels.File {
    let inputFile = InputFile.fromData(
        fileData,
      filename: fileName,
      mimeType: mimeType
    )

    return try await storage.createFile(
      bucketId: AppConfiguration.storageID,
      fileId: ID.unique(),
      file: inputFile
    )
  }

  func getFileData(fileId: String) async throws -> Data {
    let byteBuffer = try await storage.getFileView(
      bucketId: AppConfiguration.storageID,
      fileId: fileId
    )
    return Data(buffer: byteBuffer)
  }
    
    func getPreviewFileData(fileId: String) async throws -> Data {
        let byteBuffer = try await storage.getFilePreview(
        bucketId: AppConfiguration.storageID,
        fileId: fileId,
        width: 200,
        height: 150
      )
      return Data(buffer: byteBuffer)
    }


  func deleteFile(fileId: String) async throws {
    try await storage.deleteFile(
      bucketId: AppConfiguration.storageID,
      fileId: fileId
    )
  }

  // MARK: - Push Notification Methods

  func registerDeviceToken(_ token: String, userID: String) async throws {
    let data: [String: Any] = [
      "deviceToken": token,
      "userID": userID,
      "platform": "ios",
      "isActive": true,
      "createdAt": ISO8601DateFormatter().string(from: Date()),
      "updatedAt": ISO8601DateFormatter().string(from: Date())
    ]
      
      let queries = [
        Query.equal("userID", value: userID)
      ]

    let existingTokens = try await listRow(
      tableId: AppConfiguration.deviceTokensCollectionID,
      queries: queries
    )

    if let existingToken = existingTokens.rows.first {
      _ = try await updateRow(
        tableId: AppConfiguration.deviceTokensCollectionID,
        rowId: existingToken.id,
        data: data
      )
    } else {
      _ = try await createRow(
        tableId: AppConfiguration.deviceTokensCollectionID,
        data: data
      )
    }
  }

  func scheduleNotification(
    productId: String,
    productName: String,
    notificationDate: Date,
    userID: String
  ) async throws {
    let data: [String: Any] = [
      "productId": productId,
      "productName": productName,
      "notificationDate": ISO8601DateFormatter().string(from: notificationDate),
      "userId": userID,
      "isProcessed": false,
      "createdAt": ISO8601DateFormatter().string(from: Date())
    ]

      let queries = [
        Query.equal("productId", value: productId)
      ]

      let existingSchedules = try await listRow(
        tableId: AppConfiguration.notificationSchedulesCollectionID,
        queries: queries
      )
      if let existingSchedule = existingSchedules.rows.first {
        _ = try await updateRow(
          tableId: AppConfiguration.notificationSchedulesCollectionID,
          rowId: existingSchedule.id,
          data: data
        )
      } else {
        _ = try await createRow(
          tableId: AppConfiguration.notificationSchedulesCollectionID,
          data: data
        )
      }
  }

  func cancelScheduledNotification(productId: String) async throws {
      let queries = [
        Query.equal("productId", value: productId)
      ]
    let existingSchedules = try await listRow(
      tableId: AppConfiguration.notificationSchedulesCollectionID,
      queries: queries
    )

    if let existingSchedule = existingSchedules.rows.first {
      _ = try await deleteRow(
        tableId: AppConfiguration.notificationSchedulesCollectionID,
        rowId: existingSchedule.id
      )
    }
  }

  // MARK: - Helper Methods

  func extractFileId(from urlString: String) -> String? {
    guard let url = URL(string: urlString) else { return nil }

    let pathComponents = url.pathComponents
    if let filesIndex = pathComponents.firstIndex(of: "files"),
       filesIndex + 1 < pathComponents.count {
      return pathComponents[filesIndex + 1]
    }

    return nil
  }
    
}
