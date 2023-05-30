class AppwriteConstants {
  static const projectId = '646bcf2b47c19a98a510';
  static const databaseId = '646bcf8a8926eaaccbe4';
  static const endPoint = 'https://cloud.appwrite.io/v1';

  static const String usersCollection = '646bcfaea8bf229cf85c';
  static const String tweetsCollection = '646bcfbf03d127fdfe65';
  static const String notificationsCollection = '64753ef4868ae5417a98';

  static const String imagesBucket = '646bdc392f7fe3997401';

  static String imageUrl(String imageId) => '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
}
